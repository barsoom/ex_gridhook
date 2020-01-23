defmodule ExGridhookWeb.EventControllerTest do
  use ExGridhookWeb.ConnCase
  alias ExGridhook.Event
  alias ExGridhook.Repo

  test "POST /events" do
    Application.put_env(:ex_gridhook, :basic_auth_config, username: "foo", password: "baz")

    header_content = "Basic " <> Base.encode64("foo:baz")

    conn =
      build_conn()
      |> put_req_header("authorization", header_content)
      |> post("/events", _json: sendgrid_webhook_payload())

    assert response(conn, 200) == ""
    assert Repo.count(Event) == 3

    # Make sure these are serialised/deserialised correctly.
    event = Repo.first(Event)
    assert event.associated_records == [ "Item:123", "Item:456" ]

    Application.delete_env(:ex_gridhook, :basic_auth_config)
  end

  defp sendgrid_webhook_payload do
    [
      %{
        "email" => "john.doe@sendgrid.com",
        "timestamp" => 1_337_197_600,
        "smtp-id" => "<4FB4041F.6080505@sendgrid.com>",
        "sg_event_id" => "sendgrid_internal_event_id",
        "sg_message_id" => "sendgrid_internal_message_id",
        "event" => "processed",
        "category" => "category",
        "associated_records" => '["Item:123", "Item:456"]'
      },
      %{
        "email" => "john.doe@sendgrid.com",
        "timestamp" => 1_337_966_815,
        "ip" => "X.XX.XXX.XX",
        "sg_event_id" => "sendgrid_internal_event_id",
        "url" => "https://sendgrid.com",
        "sg_message_id" => "sendgrid_internal_message_id",
        "useragent" =>
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
        "event" => "click",
        "category" => "category"
      },
      %{
        "ip" => "X.XX.XXX.XX",
        "sg_user_id" => 123,
        "sg_event_id" => "sendgrid_internal_event_id",
        "sg_message_id" => "sendgrid_internal_message_id",
        "useragent" =>
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
        "event" => "group_unsubscribe",
        "email" => "john.doe@sendgrid.com",
        "timestamp" => 1_337_969_592,
        "asm_group_id" => 42,
        "category" => ["category1", "category2"]
      }
    ]
  end
end
