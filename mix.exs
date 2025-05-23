defmodule ExGridhook.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_gridhook,
      version: "0.0.1",
      elixir: ">= 0.0.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExGridhook.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, ">= 0.0.0"},
      {:gettext, ">= 0.0.0"},
      {:honeybadger, ">= 0.0.0"},
      {:jason, ">= 0.0.0"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, ">= 0.0.0"},
      {:phoenix_html, ">= 0.0.0"},
      {:phoenix_live_reload, ">= 0.0.0", only: :dev},
      {:phoenix_pubsub, ">= 2.0.0"},
      {:phoenix_view, "~> 2.0"},
      {:plug_cowboy, ">= 1.0.0"},
      {:postgrex, ">= 0.0.0"},
      {:yaml_elixir, ">= 0.0.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:req, "~> 0.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
