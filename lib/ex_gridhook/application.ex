defmodule ExGridhook.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      ExGridhook.Repo,
      ExGridhookWeb.Endpoint,
      {Phoenix.PubSub, name:  ExGridhook.PubSub},
      
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExGridhook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExGridhookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
