defmodule ExGridhookWeb.RootController do
  use ExGridhookWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "This app handles incoming sendgrid events.")
  end

  def revision(conn, _params) do
    send_resp(conn, 200, System.get_env("HEROKU_SLUG_COMMIT") || "no revision is set.")
  end
end
