defmodule ExGridhookWeb.RootControllerTest do
  use ExGridhookWeb.ConnCase

  test "GET /" do
    conn = get(build_conn(), "/")

    assert response(conn, 200) =~ "handles incoming sendgrid events"
  end

  test "GET /revision without ENV set" do
    conn = get(build_conn(), "/revision")
    assert response(conn, 200) =~ "no revision is set."
  end

  test "GET /revision with ENV set" do
    System.put_env("HEROKU_SLUG_COMMIT", "12345")

    conn = get(build_conn(), "/revision")
    assert response(conn, 200) == "12345"

    System.delete_env("HEROKU_SLUG_COMMIT")
  end
end
