# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_gridhook,
  ecto_repos: [ExGridhook.Repo]

# Configures the endpoint
config :ex_gridhook, ExGridhookWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5UYqlV7Wv8SufUN9GDvG++YgjBijdFUxWxPadMqkG+KigAtzi26jOH0R9fYjH2K8",
  render_errors: [view: ExGridhookWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExGridhook.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
