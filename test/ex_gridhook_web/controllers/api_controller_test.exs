defmodule ExGridhookWeb.ApiControllerTest do
  import Plug.BasicAuth
  use ExGridhookWeb.ConnCase
  alias ExGridhook.Event
  alias ExGridhook.Repo

  # This API is consumed by the Auctionet core repo (GridlookApiClient / GridlookEvent).
  # The routes and JSON shape here must stay compatible with that client.

  setup do
    [username, password] =
      Application.get_env(:ex_gridhook, :basic_auth_config)
      |> Enum.map(fn env -> env |> elem(1) end)

    conn =
      build_conn()
      |> put_req_header("authorization", encode_basic_auth(username, password))

    {:ok, conn: conn}
  end

  test "GET /api/v1/events returns events for a user_identifier with the expected shape", %{
    conn: conn
  } do
    Event.create_all([attributes()])

    conn = get(conn, "/api/v1/events", user_identifier: "Customer:123")
    [event] = json_response(conn, 200)

    # Keys must match GridlookEvent's vattr_initialize in the Auctionet core repo.
    assert event["email"] == "john.doe@sendgrid.com"
    assert event["name"] == "processed"
    assert event["mailer_action"] == "category#foo"
    assert event["user_identifier"] == "Customer:123"
    assert Map.has_key?(event, "category")
    assert Map.has_key?(event, "data")
    assert Map.has_key?(event, "unique_args")
    assert Map.has_key?(event, "happened_at")
    assert Map.has_key?(event, "associated_records")
  end

  test "GET /api/v1/events without user_identifier returns 400", %{conn: conn} do
    conn = get(conn, "/api/v1/events")
    assert json_response(conn, 400) == %{"error" => "You have to specify user_identifier."}
  end

  test "GET /api/v1/events/:id returns a single event", %{conn: conn} do
    Event.create_all([attributes()])
    id = Repo.first(Event).id

    conn = get(conn, "/api/v1/events/#{id}")
    event = json_response(conn, 200)

    assert event["id"] == id
    assert event["email"] == "john.doe@sendgrid.com"
  end

  test "GET /api/v1/events/:id with unknown id returns 404", %{conn: conn} do
    conn = get(conn, "/api/v1/events/0")
    assert json_response(conn, 404) == %{"error" => "Not found."}
  end

  test "POST /api/v1/personal_data/remove deletes events by email", %{conn: conn} do
    Event.create_all([attributes()])
    assert Repo.count(Event) == 1

    conn = post(conn, "/api/v1/personal_data/remove", email: "john.doe@sendgrid.com")

    assert json_response(conn, 200) == %{"removed" => 1}
    assert Repo.count(Event) == 0
  end

  test "POST /api/v1/personal_data/remove without email returns 400", %{conn: conn} do
    conn = post(conn, "/api/v1/personal_data/remove", %{})
    assert json_response(conn, 400) == %{"error" => "You have to specify email."}
  end

  defp attributes do
    %{
      "email" => "john.doe@sendgrid.com",
      "timestamp" => 1_337_197_600,
      "smtp-id" => "<4FB4041F.6080505@sendgrid.com>",
      "sg_event_id" => "sendgrid_internal_event_id",
      "sg_message_id" => "sendgrid_internal_message_id",
      "event" => "processed",
      "category" => ["category#foo", "category"],
      "user_identifier" => "Customer:123",
      "other_attribute" => 456
    }
  end
end
