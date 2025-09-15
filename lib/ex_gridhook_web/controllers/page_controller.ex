defmodule ExGridhookWeb.PageController do
  use ExGridhookWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def index(conn, _params) do
    send_resp(conn, 200, "This app handles incoming sendgrid events.")
  end

  def revision(conn, _params) do
    revision =
      case File.read("built_from_revision") do
        {:ok, body} -> body
        {:error, _reason} -> fetch_revision_from_env()
      end

    send_resp(conn, 200, revision)
  end

  def boom(_conn, _params) do
    # Used to test error reporting.
    raise "Boom!"
  end

  defp fetch_revision_from_env do
    Application.fetch_env(:ex_gridhook, :revision)
    |> elem(1)
    |> elem(1)
    |> System.get_env() || "no revision is set."
  end
end
