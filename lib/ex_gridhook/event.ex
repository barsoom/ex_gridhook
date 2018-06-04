defmodule ExGridhook.Event do
  use Ecto.Schema
  import Ecto.Query
  alias ExGridhook.Event
  alias ExGridhook.EventsData
  alias ExGridhook.Repo

  schema "events" do
    field :email, :string
    field :name, :string
    field :category, ExGridhook.YamlType
    field :data, ExGridhook.YamlType
    field :happened_at, :utc_datetime
    field :unique_args, ExGridhook.YamlType
    field :mailer_action, :string
    field :sendgrid_unique_event_id, :string

    timestamps(inserted_at: :created_at)
  end

  def create(attributes \\ %{}) do
    category = Map.get(attributes, "category")
    event = Map.get(attributes, "event")
    email = Map.get(attributes, "email")
    happened_at = Map.get(attributes, "timestamp")
    sendgrid_unique_event_id = Map.get(attributes, "sg_event_id")
    known_attributes = ["smtp-id", "attempt", "response", "url", "reason", "type", "status"]
    data = Map.take(attributes, known_attributes)
    unique_args =
      attributes
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> Map.drop([:category, :event, :email, :timestamp, :sg_event_id])

    %Event{email: email, name: event, category: category, happened_at: to_date_time(happened_at), data: data, unique_args: unique_args, mailer_action: mailer_action(category), sendgrid_unique_event_id: sendgrid_unique_event_id}
    |> Repo.insert()
    |> update_event_count
  end

  def create_all(events_attributes \\ %{}) do
    events_attributes
    |> Enum.map(&create/1)
    |> Enum.all?(fn ({status, _event}) -> status == :ok end)
    |> respond_to_create_all
  end

  defp update_event_count(event_create_results) do
    from(e in EventsData, update: [set: [total_events: fragment("COALESCE(\"total_events\", 0) + 1")]])
    |> Repo.update_all([])

    event_create_results
  end

  defp respond_to_create_all(true), do: :ok
  defp respond_to_create_all(false), do: :error

  defp to_date_time(timestamp) do
    timestamp
    |> DateTime.from_unix!
    |> Ecto.DateTime.cast!
  end

  defp mailer_action(nil), do: nil
  defp mailer_action(categories) when is_list(categories) do
    categories
    |> Enum.filter(&mailer_action/1)
    |> Enum.map(&mailer_action/1)
    |> List.first
  end
  defp mailer_action(categories) do
    if String.contains?(categories, "#") do
      categories
    else
      nil
    end
  end
end
