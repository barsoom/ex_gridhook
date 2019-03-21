defmodule ExGridhook.EventsData do
  use Ecto.Schema
  alias ExGridhook.EventsData
  alias ExGridhook.Repo

  schema "events_data" do
    field(:total_events, :integer)

    timestamps()
  end
end
