defmodule ExGridhookWeb.Component do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component, unquote(opts)
      # unimport the components which we redefine in the project
      import Phoenix.Component, except: [link: 1]
      # import ExGridhookWeb.Components.Widgets.Link

      unquote(ExGridhookWeb.verified_routes())
    end
  end
end
