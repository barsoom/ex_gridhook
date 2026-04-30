defmodule ExGridhookWeb.ErrorHTML do
  use ExGridhookWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
