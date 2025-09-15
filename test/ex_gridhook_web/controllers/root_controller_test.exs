defmodule ExGridhookWeb.PageControllerTest do
  use ExGridhookWeb.ConnCase

  test "GET /" do
    conn = get(build_conn(), "/")

    assert response(conn, 200) =~ "handles incoming sendgrid events"
  end

  test "GET /revision without built_from_revision file " do
    File.rm("built_from_revision")

    conn = get(build_conn(), "/revision")
    assert response(conn, 200) =~ "no revision is set."
  end

  test "GET /revision with ENV set" do
    File.rm("built_from_revision")

    System.put_env("HEROKU_SLUG_COMMIT", "12345")

    conn = get(build_conn(), "/revision")
    assert response(conn, 200) == "12345"

    System.delete_env("HEROKU_SLUG_COMMIT")
  end

  test "GET /revision with file built_from_revision" do
    System.delete_env("HEROKU_SLUG_COMMIT")

    File.write!("built_from_revision", "12345")

    conn = get(build_conn(), "/revision")
    assert response(conn, 200) == "12345"
  end
end
