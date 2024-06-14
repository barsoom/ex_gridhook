
defmodule ExGridhookWeb.PageController do
  use ExGridhookWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def revision(conn, _params) do
    send_resp(conn, 200, System.get_env("REVISION", "no revision is set"))
  end
end
