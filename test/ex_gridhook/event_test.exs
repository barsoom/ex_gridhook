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
    assert event.user_type == "Customer"
    assert event.user_id == 123
    assert event.user_identifier == "Customer:123"

    assert event.unique_args == %{
      "sg_message_id" => "sendgrid_internal_message_id",
      "smtp-id" => "<4FB4041F.6080505@sendgrid.com>",
      "other_attribute" => 456
    }

    assert event.sendgrid_unique_event_id == "sendgrid_internal_event_id"
    assert_in_delta(DateTime.to_unix(event.happened_at), 1_337_197_600, 1)

    # Make sure we update the total events count.
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 1
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
      "user_id" => "Customer:123",
      "other_attribute" => 456
    }
  end
end
