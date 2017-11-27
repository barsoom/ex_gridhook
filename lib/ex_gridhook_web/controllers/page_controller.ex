defmodule ExGridhookWeb.PageController do
  use ExGridhookWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
