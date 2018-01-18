defmodule ExGridhook.Repo.Migrations.CreateEventsData do
  use Ecto.Migration

  alias ExGridhook.Repo
  alias ExGridhook.EventsData
  alias ExGridhook.Event

  def change do
    create table(:events_data) do
      add :total_events, :integer

      timestamps()
    end

    flush()

    %EventsData{total_events: Repo.count(Event)}
    |> Repo.insert()
  end
end
