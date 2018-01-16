use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_gridhook, ExGridhookWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
{username, port, password} = if System.get_env("DEVBOX") do
  {"postgres", elem(System.cmd("service_port", ["postgres"]), 0), "dev"}
  else if System.get_env("CIRCLECI") do
    {"ubuntu", "5432", ""}
  else
    {System.get_env("DB_USER") || System.get_env("USER"), "5432", ""}
  end

config :ex_gridhook, ExGridhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: username,
  password: password,
  port: port,
  database: "ex_gridhook_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
