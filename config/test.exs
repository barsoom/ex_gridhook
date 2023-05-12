import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_gridhook, ExGridhookWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

devbox_port =
  if System.get_env("DEVBOX") do
    System.cmd("service_port", ["postgres"]) |> elem(0) |> String.trim()
  end

config :ex_gridhook, ExGridhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "dev",
  port: devbox_port,
  database: "ex_gridhook_test",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure Basic Auth
config :ex_gridhook, :basic_auth_config,
  username: "foo",
  password: "baz"

config :ex_gridhook,
  revision: {:system, "HEROKU_SLUG_COMMIT", "some revision"}
