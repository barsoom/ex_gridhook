defmodule ExGridhook.Repo do
  use Ecto.Repo, otp_app: :ex_gridhook

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
    get(schema, 1)
  end
end
