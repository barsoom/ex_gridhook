defmodule ExGridhookWeb.RootLive.Home do
  use ExGridhookWeb, [:live_view]

  def mount(_params, _session, socket) do
    %{sso: sso} = socket.assigns

    socket
    |> assign(page_title: "Welcome")
    # |> redirect_to_home_for_user(sso)
    |> ok
  end

  # defp redirect_to_home_for_user(socket, %{role: :driver}), do: socket |> push_navigate(to: ~p"/collections")
  # defp redirect_to_home_for_user(socket, _), do: socket
end
