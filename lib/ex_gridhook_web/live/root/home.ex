defmodule ExGridhookWeb.RootLive.Home do
  use ExGridhookWeb, [:live_view]

  def mount(_params, _session, socket) do

    socket
    |> assign(page_title: "Welcome")
    |> ok
  end
end
