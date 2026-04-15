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
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      "dev_secret_key_base_at_least_64_bytes_long_do_not_use_in_production_xxxxxxxxxxx",
  pubsub_server: ExGridhook.PubSub,
  live_view: [signing_salt: "gridhook_lv"]

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
  origin: System.get_env("HONEYBADGER_ORIGIN", "https://api.honeybadger.io"),
  breadcrumbs_enabled: true

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
