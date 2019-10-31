defmodule ExGridhook.Repo.Migrations.AddUserTypeAndUserIdToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :user_type, :string
      add :user_id, :integer
    end

    create index(:events, [:user_type, :user_id])
  end
end
