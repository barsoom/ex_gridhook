defmodule ExGridhook.Event do
  @moduledoc false

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
    field(:associated_records, {:array, :string})

    field(:user_identifier, :string)

    timestamps(inserted_at: :created_at)
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
