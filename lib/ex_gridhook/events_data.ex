defmodule ExGridhook.EventsData do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Query
  alias ExGridhook.Repo

  schema "events_data" do
    field(:total_events, :integer)

    timestamps()
  end

  def total_events do
    Repo.one(from e in __MODULE__, select: e.total_events, limit: 1) || 0
  end

  def increment(count) do
    Repo.update_all(__MODULE__, inc: [total_events: count])
  end

  def decrement(count) do
    Repo.update_all(__MODULE__, inc: [total_events: -count])
  end
end
