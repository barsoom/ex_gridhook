defmodule ExGridhookWeb.Router do
  use ExGridhookWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExGridhookWeb do
    pipe_through :browser

    get "/", RootController, :index
    get "/revision",RootController, :revision
  end

  scope "/events", ExGridhookWeb do
    pipe_through :api

    post "/events", EventController, :create
  end
end
