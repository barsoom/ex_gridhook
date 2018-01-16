use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_gridhook, ExGridhookWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
{username, port, password, db_name} = cond do
  System.get_env("DEVBOX") ->
    {"postgres", elem(System.cmd("service_port", ["postgres"]), 0), "dev", "ex_gridhook_test"}
  System.get_env("CIRCLECI") ->
    {"ubuntu", "5432", "", "circle_test"}
  _ ->
    {System.get_env("DB_USER") || System.get_env("USER"), "5432", "", "ex_gridhook_test"}
  end

config :ex_gridhook, ExGridhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: username,
  password: password,
  port: port,
  database: "ex_gridhook_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
