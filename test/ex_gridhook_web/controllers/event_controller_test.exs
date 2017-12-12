defmodule ExGridhookWeb.EventControllerTest do
  use ExGridhookWeb.ConnCase
  alias ExGridhook.Event
  alias ExGridhook.Repo

  test "POST /events" do
    conn = build_conn()
      |> post("/events", [ params: sendgrid_webhook_payload() ])
    assert response(conn, 200) == ""
    assert Repo.count(Event) == 3
  end

  defp sendgrid_webhook_payload do
    %{
      "_json" => [
        %{
          "email" => "john.doe@sendgrid.com",
          "timestamp" => 1337197600,
          "smtp-id" => "<4FB4041F.6080505@sendgrid.com>",
          "sg_event_id" => "sendgrid_internal_event_id",
          "sg_message_id" => "sendgrid_internal_message_id",
          "event" => "processed",
          "category" => "category"
        },
        %{
          "email" => "john.doe@sendgrid.com",
          "timestamp" => 1337966815,
          "ip" => "X.XX.XXX.XX",
          "sg_event_id" => "sendgrid_internal_event_id",
          "url" => "https://sendgrid.com",
          "sg_message_id" => "sendgrid_internal_message_id",
          "useragent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
          "event" => "click",
          "category" => "category"
        },
        %{
          "ip" =>  "X.XX.XXX.XX",
          "sg_user_id" => 123,
          "sg_event_id" => "sendgrid_internal_event_id",
          "sg_message_id" => "sendgrid_internal_message_id",
          "useragent" =>  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
          "event" => "group_unsubscribe",
          "email" => "john.doe@sendgrid.com",
          "timestamp" => 1337969592,
          "asm_group_id" => 42,
          "category" => ["category1", "category2"]
        }
      ]
    }
    |> Poison.encode!
  end
end
