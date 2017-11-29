defmodule ExGridhookWeb.RootControllerTest do
  use ExGridhookWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert response(conn, 200) =~ "handles incoming sendgrid events"
  end

  test "GET /revision without ENV set", %{conn: conn} do
    conn = get(conn, "/revision")
    assert response(conn, 200) =~ "no revision is set."
  end

  test "GET /revision with ENV set", %{conn: conn} do
    System.put_env("GIT_COMMIT", "12345")

    conn = get(conn, "/revision")
    assert response(conn, 200) == "12345"

    System.delete_env("GIT_COMMIT")
  end
end
