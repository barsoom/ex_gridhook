defmodule ExGridhook.EventTest do
  use ExGridhook.DataCase
  alias ExGridhook.Event
  alias ExGridhook.EventsData

  test "works" do
    # Make sure we have a events_data table
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 0

    Event.create_all([attributes()])

    event = Repo.last(Event)

    assert Repo.count(Event) == 1

    assert event.email == "john.doe@sendgrid.com"
    assert event.name == "processed"
    assert event.category == ["category#foo", "category"]
    assert event.data == %{"smtp-id" => "<4FB4041F.6080505@sendgrid.com>"}
    assert event.mailer_action == "category#foo"
    assert event.user_identifier == "Customer:123"

    assert event.unique_args == %{
             "other_attribute" => 456
           }

    assert_in_delta(DateTime.to_unix(event.happened_at), 1_337_197_600, 1)

    # Make sure we update the total events count.
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 1

    # Supports user_id (used by outbound).
    Event.create_all([
      attributes() |> Map.delete("user_identifier") |> Map.put("user_id", "Admin:123")
    ])

    event = Repo.last(Event)
    assert event.user_identifier == "Admin:123"
  end

  test "does not store outbound campaign events" do
    Event.create_all([
      Map.merge(
        attributes(),
        %{
          "environment" => "production",
          "ip" => "172.254.122.68",
          "sg_message_id" => "Na0_YttnRuaWftP_6sPMvg.filter0p1iad2-4598-5F68A5D2-22.0-12",
          "smtp-id" =>
            "<k5f68a5d2be79_43fa7aa45fd3041493@4e712b26-042a-4855-9c92-e6656a788c53.mail>",
          "tls" => 1
        }
      )
    ])

    event = Repo.last(Event)

    assert event.unique_args == %{
             "other_attribute" => 456,
             "ip" => "172.254.122.68"
           }
  end

  test "does not store some meta data as unique arguments" do
    Event.create_all([attributes()])
  end

  test "does not update total events if no event was created" do
    # Sanity
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 0

    Event.create_all([])

    # Sanity
    assert Repo.count(Event) == 0

    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 0
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
