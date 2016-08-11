# Streamex [![Build Status](https://img.shields.io/travis/sixFingers/streamex.svg)](https://travis-ci.org/sixFingers/streamex) [![Coverage Status](https://img.shields.io/coveralls/sixFingers/streamex.svg)](https://coveralls.io/github/sixFingers/streamex?branch=master)

Streamex is a [GetStream](https://getstream.io) client library for the Elixir language.

## Documentation

  - [Project page](https://sixfingers.github.io/streamex)
  - [Hex Docs](https://hexdocs.pm/streamex/0.3.0/api-reference.html)

## Installation

Add Streamex to your `mix.exs` file:

```elixir
def deps do
  [{:streamex, "~> 0.3.0"}]
end
```

then run `mix deps.get` to install the library.

## Configuration

Ensure Streamex is started before your application:

```elixir
def application do
  [applications: [:streamex]]
end
```

Then setup configuration values in your `config/[env].exs` file:

```elixir
config :streamex, region: "api_region",
                  key: "api_key",
                  secret: "api_secret"
```

## Usage

Refer to [Streamex documentation](https://sixfingers.github.io/streamex).
Usage examples may be also found in `/test` folder.
