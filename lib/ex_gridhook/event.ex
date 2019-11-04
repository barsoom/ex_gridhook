defmodule ExGridhook.Event do
  use Ecto.Schema
  alias ExGridhook.Event
  alias ExGridhook.EventsData
  alias ExGridhook.Repo
  alias Ecto.Multi
  @timestamps_opts [type: :utc_datetime]

  schema "events" do
    field(:email, :string)
    field(:name, :string)
    field(:category, ExGridhook.YamlType)
    field(:data, ExGridhook.YamlType)
    field(:happened_at, :utc_datetime)
    field(:unique_args, ExGridhook.YamlType)
    field(:mailer_action, :string)
    field(:sendgrid_unique_event_id, :string)
    field(:user_type, :string)
    field(:user_id, :integer)

    timestamps(inserted_at: :created_at)
  end

  def create_event_data(attributes \\ %{}) do
    category = Map.get(attributes, "category")
    event = Map.get(attributes, "event")
    email = Map.get(attributes, "email")
    happened_at = Map.get(attributes, "timestamp")
    sendgrid_unique_event_id = Map.get(attributes, "sg_event_id")
    user_id = parse_user_id(attributes)
    user_type = parse_user_type(attributes)
    known_attributes = ["smtp-id", "attempt", "response", "url", "reason", "type", "status"]
    data = Map.take(attributes, known_attributes)

    unique_args =
      attributes
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> Map.drop([:category, :event, :email, :timestamp, :sg_event_id, :user_type, :user_id])

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
      mailer_action: mailer_action(category),
      sendgrid_unique_event_id: sendgrid_unique_event_id,
      user_type: user_type,
      user_id: user_id,
      created_at: creation_time,
      updated_at: creation_time
    }
  end

  def create_all(events_attributes \\ %{}) do
    events = events_attributes |> Enum.map(&create_event_data/1)

    Multi.new()
    |> Multi.insert_all(:events, Event, events)
    |> Multi.update_all(:events_data, EventsData, inc: [total_events: Enum.count(events)])
    |> Repo.transaction()
  end

  defp parse_user_id(%{ "user_id" => user_id, "user_type" => _user_type }), do: user_id
  defp parse_user_id(%{ "user_id" => user_id }), do: String.split(user_id, ":") |> List.last() |> String.to_integer()
  defp parse_user_id(_other), do: nil
  defp parse_user_type(%{ "user_id" => _user_id, "user_type" => user_type }), do: user_type
  defp parse_user_type(%{ "user_id" => user_id }), do: String.split(user_id, ":") |> List.first()
  defp parse_user_type(_other), do: nil

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
end
