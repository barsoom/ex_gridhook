defmodule ExGridhookWeb.RootLive.Home do
  # use LoganWeb, [:live_view, role: :default]
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    %{sso: sso} = socket.assigns

    socket
    |> assign(page_title: gettext("Welcome"))
    |> redirect_to_home_for_user(sso)
    |> ok
  end

  defp redirect_to_home_for_user(socket, %{role: :driver}), do: socket |> push_navigate(to: ~p"/collections")
  defp redirect_to_home_for_user(socket, _), do: socket
end
