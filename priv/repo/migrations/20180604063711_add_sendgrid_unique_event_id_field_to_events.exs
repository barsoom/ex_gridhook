defmodule ExGridhook.Repo.Migrations.AddSendgridUniqueEventIdFieldToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :sendgrid_unique_event_id, :string
    end

    create index(:events, [:sendgrid_unique_event_id])
  end
end
