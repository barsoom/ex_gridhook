# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :ex_gridhook,
  ecto_repos: [ExGridhook.Repo],
    generators: [timestamp_type: :utc_datetime]


# Configures the endpoint
config :ex_gridhook, ExGridhookWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "no secret",
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ExGridhookWeb.ErrorHTML, json: ExGridhookWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExGridhook.PubSub,
  live_view: [signing_salt: "TnPLBOai"]

# config :myapp, Myapp.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  ex_gridhook: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  ex_gridhook: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :ex_gridhook, revision: {:system, "HEROKU_SLUG_COMMIT", "some revision"}

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
