defmodule Streamex.Mixfile do
  use Mix.Project

  def project do
    [app: :streamex,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.2"},
      {:joken, git: "git://github.com/bryanjos/joken.git"}
    ]
  end

  defp description do
    """
    A GetStream client for the Elixir language
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :streamex,
     maintainers: ["Ignazio Setti"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sixFingers/streamex",
              "Docs" => "http://sixfingers.github.io/streamex/"}]
  end
end
