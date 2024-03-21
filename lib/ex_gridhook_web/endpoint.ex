defmodule ExGridhookWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_gridhook

  # socket("/socket", ExGridhookWeb.UserSocket)

  @session_options [
    store: :cookie,
    key: "_ex_gridhook_key",
    signing_salt: "60/TmZ/c",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [:user_agent, session: @session_options]]

  #  # Code reloading can be explicitly enabled under the
  # # :code_reloader configuration of your endpoint.
  # if code_reloading? do
  #   socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  #   plug Phoenix.LiveReloader
  #   plug Phoenix.CodeReloader
  #   plug Phoenix.Ecto.CheckRepoStatus, otp_app: :logan
  # end

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :ex_gridhook,
    gzip: false,
    only: ExGridhookWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader

  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ExGridhookWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
