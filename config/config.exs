# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :debug

config :streamex, region: System.get_env("STREAMIO_REGION"),
                  key: System.get_env("STREAMIO_KEY") || "8andj8c67ycp",
                  secret: System.get_env("STREAMIO_SECRET") || "6anbcfx3a5awa62ehtmjfnzdn74shg9tcbbwrpfrdmeaf2t5f3pddfsj9ewpjnv7"
