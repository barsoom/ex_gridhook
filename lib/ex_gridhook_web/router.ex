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

    get "/", RootsController, :index
    get "/revision",RootsController, :revision
  end

  scope "/events", ExGridhookWeb do
    pipe_through :api

    post "/events", EventsController, :create
  end
end
