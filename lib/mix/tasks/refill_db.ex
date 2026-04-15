defmodule Mix.Tasks.RefillDb do
  @moduledoc """
  Fills the database with randomly generated events for development/testing.

  Inserts a large number of synthetic events across randomized emails, mailer
  actions, and event types. Uses concurrent batches for speed.

  Usage:
      mix refill_db
      mix refill_db --total 100000 --batch-size 1000 --concurrency 4
  """

  use Mix.Task

  alias ExGridhook.{Event, EventsData, Repo}

  @shortdoc "Fill the database with synthetic events"

  @default_total 417_462_507
  @default_batch_size 5_000
  @default_concurrency 8

  @mailer_actions [
    {"SavedSearchesMailer", "SavedSearchesMailer#build"},
    {"Online::AuctionReminderMailer", "Online::AuctionReminderMailer#build"},
    {"CustomerMailer", "CustomerMailer#welcome"},
    {"BidMailer", "BidMailer#outbid"}
  ]

  @event_names ~w(processed dropped delivered deferred bounce open click spamreport unsubscribe)

  def run(args) do
    if Mix.env() == :prod do
      Mix.raise("mix refill_db cannot be run in production")
    end

    Mix.Task.run("app.start")

    {opts, _, _} =
      OptionParser.parse(args,
        strict: [total: :integer, batch_size: :integer, concurrency: :integer]
      )

    total = Keyword.get(opts, :total, @default_total)
    batch_size = Keyword.get(opts, :batch_size, @default_batch_size)
    concurrency = Keyword.get(opts, :concurrency, @default_concurrency)
    num_batches = ceil(total / batch_size)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Mix.shell().info(
      "Inserting ~#{total} events in #{num_batches} batches of #{batch_size} (concurrency: #{concurrency})"
    )

    start = System.monotonic_time(:second)

    1..num_batches
    |> Task.async_stream(
      fn batch_num ->
        {count, _} = Repo.insert_all(Event, build_batch(batch_size, now))
        EventsData.increment(count)

        if rem(batch_num, 500) == 0 do
          elapsed = System.monotonic_time(:second) - start
          done = batch_num * batch_size
          rate = div(done, max(elapsed, 1))
          eta = div(total - done, max(rate, 1))
          Mix.shell().info("#{done}/#{total} | #{rate}/s | ETA #{div(eta, 60)}m")
        end
      end,
      max_concurrency: concurrency,
      timeout: :infinity
    )
    |> Stream.run()

    elapsed = System.monotonic_time(:second) - start
    Mix.shell().info("Done in #{elapsed}s")
  end

  defp build_batch(batch_size, now) do
    Enum.map(1..batch_size, fn _ ->
      {mailer_module, mailer_action} = Enum.random(@mailer_actions)
      buyer_id = :rand.uniform(999_999)
      name = Enum.random(@event_names)

      %{
        email: "user#{:rand.uniform(10_000)}@example.com",
        name: name,
        category: [mailer_module, mailer_action],
        data:
          if name in ["delivered", "processed"] do
            %{"smtp-id" => "<msg_#{:rand.uniform(999_999)}@mail>"}
          else
            %{}
          end,
        happened_at: DateTime.add(now, -:rand.uniform(365 * 24 * 3600), :second),
        unique_args: %{
          "arguments" => Jason.encode!(%{buyer_id: buyer_id}),
          "sg_message_id" => "msg_#{:rand.uniform(999_999_999)}.0"
        },
        mailer_action: mailer_action,
        associated_records: [],
        user_identifier: "Buyer:#{buyer_id}",
        created_at: now,
        updated_at: now
      }
    end)
  end
end
