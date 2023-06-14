# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :ex_gridhook,
  ecto_repos: [ExGridhook.Repo]

# Configures the endpoint
config :ex_gridhook, ExGridhookWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "no secret",
  pubsub_server: ExGridhook.PubSub

config :ex_gridhook,
  revision: {:system, "HEROKU_SLUG_COMMIT", "some revision"}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Basic Auth
config :ex_gridhook, :basic_auth_config,
  username: System.get_env("BASIC_AUTH_USERNAME"),
  password: System.get_env("BASIC_AUTH_PASSWORD")

# Configure Phoenix to use it for JSON encoding
config :phoenix, :json_library, Jason

config :honeybadger,
  # https://github.com/honeybadger-io/honeybadger-elixir#filtering-sensitive-data
  filter: Honeybadger.Filter.Default,
  filter_keys: [:email],
  api_key: System.get_env("HONEYBADGER_API_KEY"),
  breadcrumbs_enabled: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
