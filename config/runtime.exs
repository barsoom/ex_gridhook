import Config

if config_env() == :prod do
  port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"

  config :ex_gridhook, ExGridhookWeb.Endpoint,
    load_from_system_env: true,
    url: [scheme: "https", host: "gridhook.auctionet.dev", port: 443],
    force_ssl: [rewrite_on: [:x_forwarded_proto]],
    cache_static_manifest: "priv/static/cache_manifest.json",
    http: [:inet6, port: port]

  config :logger, level: System.get_env("LOG_LEVEL") || :info

  sso_request_url = System.get_env("SSO_REQUEST_URL")

  sso_base_url =
    case sso_request_url do
      nil ->
        nil

      url ->
        uri = URI.parse(url)
        "#{uri.scheme}://#{uri.host}"
    end

  config :ex_gridhook,
    sso_secret_key: System.get_env("SSO_SECRET_KEY"),
    sso_request_url: sso_request_url,
    sso_base_url: sso_base_url,
    env: "production"

  # Configure the database
  config :ex_gridhook, ExGridhook.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_CONNECTION_POOL_URL") || System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true,
    ssl_opts: [verify: :verify_none],
    prepare: :unnamed
end

if config_env() != :test do
  sentry_dsn = System.get_env("SENTRY_DSN")

  if sentry_dsn do
    config :ex_gridhook, :logger, [
      {:handler, :ex_gridhook_sentry_log_handler, Sentry.LoggerHandler,
       %{config: %{metadata: :all}}}
    ]
  end

  config :sentry,
    dsn: sentry_dsn,
    environment_name: System.get_env("SENTRY_ENVIRONMENT", Atom.to_string(config_env()))
end
