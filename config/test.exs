import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_gridhook, ExGridhookWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
{username, port, password, db_name, db_host} =
  cond do
    System.get_env("DEVBOX") ->
      {"postgres", System.cmd("service_port", ["postgres"]) |> elem(0) |> String.trim(), "dev",
       "ex_gridhook_test", "localhost"}

    System.get_env("CIRCLECI") ->
      {"ubuntu", "5432", "", "circle_test", "postgres"}

    true ->
      {System.get_env("DB_USER") || System.get_env("USER"), "5432", "test", "ex_gridhook_test",
       "postgres"}
  end

config :ex_gridhook, ExGridhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: username,
  password: password,
  port: port,
  database: "ex_gridhook_test",
  hostname: db_host,
  pool: Ecto.Adapters.SQL.Sandbox

# Configure Basic Auth
config :ex_gridhook, :basic_auth_config,
  username: "foo",
  password: "baz"

config :ex_gridhook,
  revision: {:system, "HEROKU_SLUG_COMMIT", "some revision"}
