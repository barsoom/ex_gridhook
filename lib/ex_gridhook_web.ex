defmodule ExGridhookWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ExGridhookWeb, :controller
      use ExGridhookWeb, :live_view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets events dinomail.gif favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: ExGridhookWeb
      import Plug.Conn
      import ExGridhookWeb.Router.Helpers
      use Gettext, backend: ExGridhookWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {ExGridhookWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML
      use PhoenixHTMLHelpers

      import Phoenix.LiveView.Helpers
      import ExGridhookWeb.CoreComponents

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ExGridhookWeb.Endpoint,
        router: ExGridhookWeb.Router,
        statics: ExGridhookWeb.static_paths()
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Plug.BasicAuth
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ExGridhookWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
