defmodule ExGridhook.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Query
  alias ExGridhook.Event
  alias ExGridhook.EventsData
  alias ExGridhook.Repo
  alias Ecto.Multi
  @timestamps_opts [type: :utc_datetime]

  @event_types ~w(processed dropped delivered deferred bounce open click spamreport unsubscribe)

  @event_descriptions %{
    "processed" => "Message has been received and is ready to be delivered.",
    "dropped" =>
      "You may see the following drop reasons: invalid SMTPAPI header, spam content (if spam checker app enabled), unsubscribed address, bounced address, spam reporting address, invalid.",
    "delivered" => "Message has been successfully delivered to the receiving server.",
    "deferred" => "Recipient's email server temporarily rejected message.",
    "bounce" => "Receiving server could not or would not accept message.",
    "open" => "Recipient has opened the HTML message.",
    "click" => "Recipient clicked on a link within the message.",
    "spamreport" => "Recipient marked message as spam.",
    "unsubscribe" => "Recipient clicked on message's subscription management link."
  }

  schema "events" do
    field(:email, :string)
    field(:name, :string)
    field(:category, ExGridhook.YamlType)
    field(:data, ExGridhook.YamlType)
    field(:happened_at, :utc_datetime)
    field(:unique_args, ExGridhook.YamlType)
    field(:mailer_action, :string)
    field(:associated_records, {:array, :string})

    field(:user_identifier, :string)

    timestamps(inserted_at: :created_at)
  end

  def event_types, do: @event_types
  def event_description(name), do: Map.get(@event_descriptions, name, "No description")

  def total_events, do: EventsData.total_events()

  def newest_time do
    Repo.one(from e in __MODULE__, select: max(e.happened_at))
  end

  def oldest_time do
    Repo.one(from e in __MODULE__, select: min(e.happened_at))
  end

  # Uses a recursive SQL query to efficiently find distinct mailer actions on large tables.
  # See: http://zogovic.com/post/44856908222/optimizing-postgresql-query-for-distinct-values
  def mailer_actions do
    sql = """
    WITH RECURSIVE t(n) AS (
        SELECT MIN(mailer_action) FROM events
      UNION
        SELECT (SELECT mailer_action FROM events WHERE mailer_action > n ORDER BY mailer_action LIMIT 1)
        FROM t WHERE n IS NOT NULL
    )
    SELECT n FROM t;
    """

    %{rows: rows} = Repo.query!(sql)
    rows |> List.flatten() |> Enum.reject(&is_nil/1)
  end

  def query_by_user_identifier(user_identifier) do
    from(e in __MODULE__, where: e.user_identifier == ^user_identifier)
  end

  def with_email_if_present(query, email) when email in [nil, ""], do: query

  def with_email_if_present(query, email) do
    downcased = String.downcase(email)
    from(e in query, where: e.email == ^downcased)
  end

  def with_name_if_present(query, name) when name in [nil, ""], do: query
  def with_name_if_present(query, name), do: from(e in query, where: e.name == ^name)

  def with_mailer_action_if_present(query, action) when action in [nil, ""], do: query

  def with_mailer_action_if_present(query, action),
    do: from(e in query, where: e.mailer_action == ^action)

  def with_associated_record_if_present(query, record) when record in [nil, ""], do: query

  def with_associated_record_if_present(query, record) do
    from(e in query, where: fragment("? @> ?", e.associated_records, ^[record]))
  end

  def recent_first(query), do: from(e in query, order_by: [desc: e.happened_at, desc: e.id])

  def paginate(query, page, per) do
    from(e in query, limit: ^per, offset: ^((page - 1) * per))
  end

  def remove_by_email(email) do
    downcased = String.downcase(email)
    {count, _} = Repo.delete_all(from e in __MODULE__, where: e.email == ^downcased)
    EventsData.decrement(count)
    count
  end

  def create_event_data(attributes \\ %{}) do
    category = Map.get(attributes, "category")
    event = Map.get(attributes, "event")
    email = Map.get(attributes, "email")
    happened_at = Map.get(attributes, "timestamp")
    user_identifier = Map.get(attributes, "user_identifier") || Map.get(attributes, "user_id")
    associated_records = Map.get(attributes, "associated_records", "[]") |> Jason.decode!()
    known_attributes = ["smtp-id", "attempt", "response", "url", "reason", "type", "status"]
    data = Map.take(attributes, known_attributes)

    unique_args =
      attributes
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> Map.drop(
        [
          :category,
          :associated_records,
          :event,
          :email,
          :timestamp,
          :sg_event_id,
          :user_type,
          :user_id,
          :user_identifier
        ] ++
          Enum.map(known_attributes, &String.to_atom/1) ++
          unique_args_not_to_store()
      )

    creation_time =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    %{
      email: email,
      name: event,
      category: category,
      happened_at: to_date_time(happened_at),
      data: data,
      unique_args: unique_args,
      associated_records: associated_records,
      mailer_action: mailer_action(category),
      user_identifier: user_identifier,
      created_at: creation_time,
      updated_at: creation_time
    }
  end

  def create_all(events_attributes \\ %{}) do
    events =
      events_attributes
      |> Enum.reject(&(Map.has_key?(&1, "campaign_id") && Map.has_key?(&1, "outbound_id")))
      |> Enum.map(&create_event_data/1)

    Multi.new()
    |> Multi.insert_all(:events, Event, events)
    |> Multi.update_all(:events_data, EventsData, inc: [total_events: Enum.count(events)])
    |> Repo.transaction()
  end

  defp to_date_time(timestamp) do
    timestamp
    |> DateTime.from_unix!()
  end

  defp mailer_action(nil), do: nil

  defp mailer_action(categories) when is_list(categories) do
    categories
    |> Enum.filter(&mailer_action/1)
    |> Enum.map(&mailer_action/1)
    |> List.first()
  end

  defp mailer_action(categories) do
    if String.contains?(categories, "#") do
      categories
    else
      nil
    end
  end

  # We remove some of the meta data that isn't really useful and since we want to limit db size.
  defp unique_args_not_to_store do
    [
      :environment,
      :tls,
      :url,
      :url_offset
    ]
  end
end
