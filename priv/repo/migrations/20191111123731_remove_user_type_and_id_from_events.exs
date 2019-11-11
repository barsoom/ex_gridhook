defmodule ExGridhook.Repo.Migrations.RemoveUserTypeAndIdFromEvents do
  use Ecto.Migration

  def change do
    drop index(:events, [:user_type, :user_id])

    alter table(:events) do
      remove :user_id
      remove :user_type
    end
  end
end
