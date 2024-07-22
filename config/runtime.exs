import Config

if config_env() == :prod do
  port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"

  config :ex_gridhook, ExGridhookWeb.Endpoint,
    load_from_system_env: true,
    url: [scheme: "https", host: "auctionet-ex-gridhook.herokuapp.com", port: 443],
    force_ssl: [rewrite_on: [:x_forwarded_proto]],
    cache_static_manifest: "priv/static/cache_manifest.json",
    http: [:inet6, port: port]

  config :logger, level: System.get_env("LOG_LEVEL") || :info

  # Configure the database
  config :ex_gridhook, ExGridhook.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_CONNECTION_POOL_URL") || System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true,
    ssl_opts: [verify: :verify_none],
    prepare: :unnamed
end
