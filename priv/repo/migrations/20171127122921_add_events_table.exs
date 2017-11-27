defmodule ExGridhook.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :email, :string
      add :name, :string
      add :category, :text
      add :data, :text
      add :happened_at, :datetime
      add :unique_args, :text
      add :mailer_action, :string

      timestamps(inserted_at: :created_at)

    end

    create index(:events, [:email])
    create index(:events, [:happened_at, :id])
    create index(:events, [:mailer_action, :happened_at, :id])
    create index(:events, [:name])
  end
end
