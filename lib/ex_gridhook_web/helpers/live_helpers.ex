defmodule ExGridhookWeb.Helpers.LiveHelpers do
  @moduledoc """
  Helpers for liveviews
  """
  def ok(socket), do: {:ok, socket}
  def ok(socket, opts), do: {:ok, socket, opts}

  def noreply(socket), do: {:noreply, socket}
end
