defmodule Mix.Tasks.RemoveEvents do
  @moduledoc """
  Removes old events based on the NUMBER_OF_MONTHS_TO_KEEP_EVENTS_FOR environment variable.

  Deletes:
  - Events older than NUMBER_OF_MONTHS_TO_KEEP_EVENTS_FOR months (general limit)
  - SavedSearchMailer#build events older than 2 months
  - All campaign events (those with campaign_id in unique_args)

  Usage:
      mix remove_events
  """

  use Mix.Task

  import Ecto.Query
  alias ExGridhook.{Event, EventsData, Repo}

  @shortdoc "Remove old events according to retention policy"

  def run(_args) do
    Mix.Task.run("app.start")

    months = System.get_env("NUMBER_OF_MONTHS_TO_KEEP_EVENTS_FOR")

    if is_nil(months) || months == "" do
      Mix.shell().info("Skipping: NUMBER_OF_MONTHS_TO_KEEP_EVENTS_FOR is not set.")
    else
      general_limit = months_ago(String.to_integer(months))
      saved_search_limit = months_ago(2)

      remove_events(
        from(e in Event, where: e.happened_at < ^general_limit),
        "Deleted events older than #{general_limit}"
      )

      remove_events(
        from(e in Event,
          where:
            e.mailer_action == "SavedSearchMailer#build" and e.happened_at < ^saved_search_limit
        ),
        "Deleted SavedSearchMailer#build events older than 2 months"
      )

      remove_events(
        from(e in Event, where: like(fragment("unique_args::text"), "%campaign_id%")),
        "Deleted campaign events"
      )
    end
  end

  defp remove_events(query, message) do
    {count, _} = Repo.delete_all(query)
    EventsData.decrement(count)
    Mix.shell().info(message)
  end

  defp months_ago(months) do
    DateTime.utc_now()
    |> DateTime.add(-months * 30 * 24 * 60 * 60, :second)
    |> DateTime.truncate(:second)
  end
end
