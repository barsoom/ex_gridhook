defmodule ExGridhookWeb.EventsLive do
  use ExGridhookWeb, :live_view

  on_mount ExGridhookWeb.Auth.SsoOnMount

  alias ExGridhook.Event
  alias ExGridhook.Repo

  @per_page 100

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ExGridhook.PubSub, "events")

    {:ok,
     assign(socket,
       mailer_actions: Event.mailer_actions(),
       total_count: Event.total_events(),
       newest_time: Event.newest_time(),
       oldest_time: Event.oldest_time(),
       frozen: false,
       pending_count: 0
     )}
  end

  def handle_params(params, _uri, socket) do
    email = clean(params["email"])
    name = clean(params["name"])
    mailer_action = clean(params["mailer_action"])
    associated_record = clean(params["associated_record"])
    page = max(String.to_integer(params["page"] || "1"), 1)

    socket =
      socket
      |> assign(
        email: email,
        name: name,
        mailer_action: mailer_action,
        associated_record: associated_record,
        page: page
      )
      |> load_events()

    {:noreply, socket}
  end

  def handle_info(:new_events, %{assigns: %{frozen: true}} = socket) do
    {:noreply, update(socket, :pending_count, &(&1 + 1))}
  end

  def handle_info(:new_events, socket) do
    {:noreply, reload_stats(socket) |> load_events()}
  end

  def handle_event("toggle_freeze", _params, socket) do
    if socket.assigns.frozen do
      socket =
        socket
        |> assign(frozen: false, pending_count: 0)
        |> reload_stats()
        |> load_events()

      {:noreply, socket}
    else
      {:noreply, assign(socket, frozen: true)}
    end
  end

  def handle_event("filter", params, socket) do
    filter_params =
      params
      |> Map.take(["email", "name", "mailer_action", "associated_record"])
      |> Enum.reject(fn {_k, v} -> v == "" end)
      |> Map.new()

    {:noreply, push_patch(socket, to: build_path(filter_params))}
  end

  def handle_event("clear_filters", _params, socket) do
    {:noreply, push_patch(socket, to: "/")}
  end

  # Build a URL path merging current filters with given overrides.
  # Overrides use atom keys for easy calling from templates (no map literal syntax).
  def filter_path(assigns, overrides \\ []) do
    base = [
      {"email", assigns[:email]},
      {"name", assigns[:name]},
      {"mailer_action", assigns[:mailer_action]},
      {"associated_record", assigns[:associated_record]}
    ]

    merged =
      overrides
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      |> then(&Enum.into(&1, Map.new(base)))
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    build_path(merged)
  end

  defp load_events(socket) do
    %{
      email: email,
      name: name,
      mailer_action: mailer_action,
      associated_record: associated_record,
      page: page
    } = socket.assigns

    events =
      Event
      |> Event.with_email_if_present(email)
      |> Event.with_name_if_present(name)
      |> Event.with_mailer_action_if_present(mailer_action)
      |> Event.with_associated_record_if_present(associated_record)
      |> Event.recent_first()
      |> Event.paginate(page, @per_page)
      |> Repo.all()

    assign(socket, events: events)
  end

  defp reload_stats(socket) do
    assign(socket,
      total_count: Event.total_events(),
      newest_time: Event.newest_time(),
      oldest_time: Event.oldest_time()
    )
  end

  defp build_path(params) do
    query = URI.encode_query(params)
    if query == "", do: "/", else: "/?#{query}"
  end

  defp clean(nil), do: nil
  defp clean(""), do: nil
  defp clean(value), do: String.trim(value)

  def has_extra_data?(event) do
    map_size(event.data || %{}) > 0 or
      (event.associated_records || []) != [] or
      map_size(event.unique_args || %{}) > 0
  end

  def filtered?(email, name, mailer_action) do
    Enum.any?([email, name, mailer_action], &(not is_nil(&1)))
  end

  def format_time(nil), do: "-"

  def format_time(%DateTime{} = dt) do
    {:ok, local_dt} = DateTime.shift_zone(dt, "Europe/Stockholm")
    Calendar.strftime(local_dt, "%-d %b %Y at %H:%M:%S %z")
  end

  def format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.intersperse([","])
    |> List.flatten()
    |> Enum.reverse()
    |> Enum.join()
  end

  def format_number(n), do: to_string(n)

  def inspect_value(value) when is_map(value) do
    value
    |> Enum.map_join("\n", fn {k, v} ->
      v_str = if is_binary(v), do: v, else: inspect(v)
      "#{k} = #{v_str}"
    end)
  end

  def inspect_value(value) when is_list(value), do: Enum.join(value, "\n")
  def inspect_value(value), do: inspect(value)

  def smtp_id(event) do
    get_in(event.data || %{}, ["smtp-id"])
  end

  def gravatar_url(smtp_id) do
    hash = Base.encode16(:crypto.hash(:md5, smtp_id), case: :lower)
    "//www.gravatar.com/avatar/#{hash}?s=40&r=any&default=identicon&forcedefault=1"
  end
end
