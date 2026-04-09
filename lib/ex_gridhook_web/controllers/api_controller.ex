defmodule ExGridhookWeb.ApiController do
  use ExGridhookWeb, :controller

  alias ExGridhook.{Event, Repo}

  def events(conn, params) do
    user_identifier = params["user_identifier"] || params["user_id"]

    if is_nil(user_identifier) || user_identifier == "" do
      conn
      |> put_status(400)
      |> json(%{error: "You have to specify user_identifier."})
    else
      page = String.to_integer(params["page"] || "1")
      per = String.to_integer(params["per_page"] || "25")

      events =
        Event.query_by_user_identifier(user_identifier)
        |> Event.with_name_if_present(params["name"])
        |> Event.with_mailer_action_if_present(params["mailer_action"])
        |> Event.with_associated_record_if_present(params["associated_record"])
        |> Event.recent_first()
        |> Event.paginate(page, per)
        |> Repo.all()

      json(conn, Enum.map(events, &serialize_event/1))
    end
  end

  def event(conn, %{"id" => id}) do
    case Repo.get(Event, id) do
      nil -> conn |> put_status(404) |> json(%{error: "Not found."})
      event -> json(conn, serialize_event(event))
    end
  end

  def remove_personal_data(conn, params) do
    email = params["email"]

    if is_nil(email) || email == "" do
      conn
      |> put_status(400)
      |> json(%{error: "You have to specify email."})
    else
      count = Event.remove_by_email(email)
      json(conn, %{removed: count})
    end
  end

  # NOTE: If you add, remove or rename keys, also change `GridlookEvent` in the Auctionet core repo to match.
  defp serialize_event(event) do
    %{
      id: event.id,
      category: event.category,
      data: event.data,
      email: event.email,
      happened_at: event.happened_at,
      mailer_action: event.mailer_action,
      name: event.name,
      unique_args: event.unique_args,
      user_identifier: event.user_identifier,
      associated_records: event.associated_records
    }
  end
end
