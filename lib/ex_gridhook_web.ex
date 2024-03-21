defmodule ExGridhookWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ExGridhookWeb, :controller
      use ExGridhookWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(css fonts images js favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: ExGridhookWeb
      import Plug.Conn
      import ExGridhookWeb.Router.Helpers
      import ExGridhookWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view(opts \\ []) do
    quote do
      @moduledoc false
      use Phoenix.LiveView,
        layout: {ExGridhookWeb.PageLayouts, :app}

      # import MapPipe

      # the require is here only to get rid of a warning about the callback not being defined,
      # marking this as a compilation dependency seems to fix that
      # require ExGridhookWeb.Auth.SSO
      # on_mount ExGridhookWeb.Auth.SSO

      # case unquote(opts) |> Keyword.fetch(:role) do
      #   {:ok, role} ->
      #     on_mount {ExGridhookWeb.Auth.RoleAuthorizer, role}

      #   :error ->
      #     raise "LoganWeb requires a :role option for :live_view (use :default to allow all roles)"
      # end

      # if Application.compile_env(:logan, :sandbox) do
      #   on_mount LoganWeb.Hooks.AllowEctoSandbox
      # end

      # on_mount {LoganWeb.Localize, LoganWeb.Gettext}
      # on_mount LoganWeb.Hooks.LiveFlash
      # on_mount LoganWeb.Hooks.Presence

      # unquote(html_helpers())
      # unquote(live_helpers())

      #live_helpers()
      import LoganWeb.Helpers.Concurrent
      import LoganWeb.Helpers.EventProcessor
      import LoganWeb.Helpers.LiveHelpers
      import LoganWeb.Hooks.LiveFlash, only: [push_flash: 3]

      # html_helpers()
      #
      import Phoenix.HTML
      import Phoenix.HTML.Form

      # Core UI components; put smaller components that you want to be available
      # globally into CoreComponents.__using__/1
      use LoganWeb.Component
      use LoganWeb.CoreComponents

      import LoganWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

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
