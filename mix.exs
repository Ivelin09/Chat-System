defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.12-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :corsica]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:amnesia, "~> 0.2.8"},
      {:cowboy, "~> 2.7.0"},
      {:poison, "~> 5.0"},
      {:joken, "~> 2.0-rc0"},
      {:crypto_rand, "~> 1.0.0"},
      {:cors_plug, "~> 3.0"},
      {:plug, "~> 1.0"},
      {:corsica, "~> 1.0"}
    ]
  end
end
