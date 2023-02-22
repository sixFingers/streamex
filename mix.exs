defmodule Streamex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :streamex,
      name: "Streamex",
      source_url: "https://github.com/sixFingers/streamex",
      homepage_url: "http://sixfingers.github.io/streamex",
      version: "0.4.0",
      elixir: "~> 1.13",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:logger, :httpoison, :timex],
      extra_applications: [:joken, :poison, :hackney]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8 or ~> 2.0"},
      {:poison, "~> 5.0"},
      {:joken, "~> 2.6.0"},
      {:timex, "~> 3.7.6"},
      {:ex_doc, "~> 0.29.1", only: :dev},
      {:exvcr, "~> 0.13.5", only: :test},
      {:excoveralls, "~> 0.15.3", only: :test}
    ]
  end

  defp description do
    """
    A GetStream client for the Elixir language
    """
  end

  defp package do
    [
      name: :streamex,
      maintainers: ["Ignazio Setti"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/sixFingers/streamex",
        "Docs" => "http://sixfingers.github.io/streamex"
      }
    ]
  end
end
