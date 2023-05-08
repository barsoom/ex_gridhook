defmodule ExGridhook.EventsData do
  @moduledoc false

  use Ecto.Schema

  schema "events_data" do
    field(:total_events, :integer)

    timestamps()
  end
end
