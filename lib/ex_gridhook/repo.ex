defmodule ExGridhook.Repo do
  use Ecto.Repo,
    otp_app: :ex_gridhook,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def count(schema) do
    aggregate(schema, :count, :id)
  end

  def first(schema) do
    from(x in schema, order_by: [asc: x.id], limit: 1)
    |> one
  end

  def last(schema) do
    from(x in schema, order_by: [desc: x.id], limit: 1)
    |> one
  end
end
