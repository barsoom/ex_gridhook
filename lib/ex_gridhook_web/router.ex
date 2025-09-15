defmodule ExGridhookWeb.Router do
  use ExGridhookWeb, :router
  # use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExGridhookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:authenticate_with_basic_auth)
  end

  scope "/", ExGridhookWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/revision", PageController, :revision
    get "/boom", PageController, :boom
  end

  scope "/events", ExGridhookWeb do
    pipe_through :api

    resources("/", EventController, only: [:create])
  end

  defp authenticate_with_basic_auth(conn, _) do
    basic_auth(conn, Application.get_env(:ex_gridhook, :basic_auth_config))
  end
end
