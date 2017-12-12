defmodule ExGridhookWeb.EventController do
  use ExGridhookWeb, :controller

  def create(conn, %{"params" => params}) do
    params
    |> extract_payload
    |> create_events(conn)
  end

  defp extract_payload(params) do
    params
    |> Poison.decode!
    |> Map.fetch!("_json")
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
