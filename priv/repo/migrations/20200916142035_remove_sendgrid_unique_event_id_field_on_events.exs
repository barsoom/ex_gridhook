defmodule ExGridhook.Repo.Migrations.RemoveSendgridUniqueEventIdFieldOnEvents do
  use Ecto.Migration

  def change do
    drop(index(:events, [:sendgrid_unique_event_id]))

    alter table(:events) do
      remove(:sendgrid_unique_event_id)
    end
  end
end
