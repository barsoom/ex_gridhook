defmodule ExGridhookWeb.RootController do
  use ExGridhookWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "This app handles incoming sendgrid events.")
  end

  def revision(conn, _params) do
    revision =
      case File.read("/opt/app/built_from_revision") do
        {:ok, body} -> body
        {:error, _reason} -> Application.get_env(:ex_gridhook, :revision)
      end

    conn
    |> send_resp(200, revision)
  end

  def boom(_conn, _params) do
    # Used to test error reporting.
    raise "Boom!"
  end
end
