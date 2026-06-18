defmodule Mix.Tasks.DatabaseTuning do
  @moduledoc """
  Runs `VACUUM ANALYZE` on the database to reclaim space and refresh planner statistics.

  Scheduled daily in production (see the gridhook cron in the stack repo).

  Usage:
      mix database_tuning
  """

  use Mix.Task

  alias ExGridhook.Repo

  @shortdoc "Run VACUUM ANALYZE on the database"

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("Tuning database.")
    # VACUUM cannot run inside a transaction block, so disable Ecto's wrapping.
    Repo.query!("VACUUM ANALYZE;", [], timeout: :infinity)
    Mix.shell().info("Database tuning done.")
  end
end
