use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_gridhook, ExGridhookWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ex_gridhook, ExGridhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || System.get_env("USER"),
  password: "",
  database: "ex_gridhook_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
