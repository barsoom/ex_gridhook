defmodule ExGridhook.Repo.Migrations.AddAssociatedRecordsToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :associated_records, {:array, :string}, null: false, default: []
    end

    create index(:events, :associated_records, using: "GIN")
  end
end
