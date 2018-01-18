defmodule ExGridhookWeb.EventController do
  use ExGridhookWeb, :controller

  plug BasicAuth, use_config: {:ex_gridhook, :basic_auth_config}

  def create(conn, %{"_json" => params}) do
    params
    |> create_events(conn)
  end

  defp create_events(attributes, conn) do
    ExGridhook.Event.create_all(attributes)
    |> respond_to_create(conn)
  end

  defp respond_to_create(:ok, conn) do
    conn
    |> send_resp(200, "")
  end

  defp respond_to_create(:error, conn) do
    conn
    |> send_resp(400, "")
  end
end
