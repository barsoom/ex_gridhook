defmodule ExGridhook.EventTest do
  use ExGridhook.DataCase
  alias ExGridhook.Event
  alias ExGridhook.EventsData

  test "works" do
    # Make sure we have a events_data table
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 0

    Event.create_all([attributes()])

    event = Event |> last |> Repo.one

    assert Repo.count(Event) == 1

    assert event.email == "john.doe@sendgrid.com"
    assert event.name == "processed"
    assert event.category == ["category#foo", "category"]
    assert event.data == %{"smtp-id" => "<4FB4041F.6080505@sendgrid.com>"}
    assert event.mailer_action == "category#foo"
    assert event.unique_args == Map.drop(attributes, ["email", "category", "event", "timestamp"])
    assert_in_delta(DateTime.to_unix(event.happened_at), 1337197600, 1)

    # Make sure we update the total events count.
    assert Repo.count(EventsData) == 1
    assert Repo.first(EventsData).total_events == 1
  end

  defp attributes do
    %{
      "email" => "john.doe@sendgrid.com",
      "timestamp" => 1337197600,
      "smtp-id" => "<4FB4041F.6080505@sendgrid.com>",
      "sg_event_id" => "sendgrid_internal_event_id",
      "sg_message_id" => "sendgrid_internal_message_id",
      "event" => "processed",
      "category" => ["category#foo", "category"]
    }
  end
end
