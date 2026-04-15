defmodule ExGridhookWeb.Router do
  use ExGridhookWeb, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ExGridhookWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :jwt_auth do
    plug(ExGridhookWeb.Auth.JwtPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:authenticate_with_basic_auth)
  end

  scope "/", ExGridhookWeb do
    pipe_through([:browser, :jwt_auth])

    live("/", EventsLive)
  end

  scope "/", ExGridhookWeb do
    pipe_through(:browser)

    get("/revision", RootController, :revision)
    get("/boom", RootController, :boom)
  end

  scope "/events", ExGridhookWeb do
    pipe_through(:api)

    resources("/", EventController, only: [:create])
  end

  scope "/api/v1", ExGridhookWeb do
    pipe_through(:api)

    get("/events", ApiController, :events)
    get("/events/:id", ApiController, :event)
    delete("/personal_data", ApiController, :remove_personal_data)
  end

  defp authenticate_with_basic_auth(conn, _) do
    basic_auth(conn, Application.get_env(:ex_gridhook, :basic_auth_config))
  end
end
