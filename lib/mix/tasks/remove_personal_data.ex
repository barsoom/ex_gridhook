defmodule Mix.Tasks.RemovePersonalData do
  @moduledoc """
  Removes all events for a given email address (GDPR deletion).

  Usage:
      mix remove_personal_data EMAIL

  Example:
      mix remove_personal_data user@example.com
  """

  use Mix.Task

  alias ExGridhook.Event

  @shortdoc "Remove all events for a given email (GDPR)"

  def run([email]) do
    Mix.Task.run("app.start")

    count = Event.remove_by_email(email)
    Mix.shell().info("Removed #{count} event(s) for #{email}.")
  end

  def run(_) do
    Mix.raise("Usage: mix remove_personal_data EMAIL")
  end
end
