defmodule ExGridhook.Repo.Migrations.AddUserIdentifierToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :user_identifier, :string
    end

    create index(:events, :user_identifier)
  end
end
