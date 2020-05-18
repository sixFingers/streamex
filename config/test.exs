# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :streamex, region: "",
                  key: "py7b6dkg8fm4",
                  secret: "4rze5eevh7dsy2ae89nnsn32v4qd7tzjnhtx8qf45hqvax9akrdj9ppg4k4vz2w2"


#                   export STREAM_DEV_APP_ID=47380
# export STREAM_DEV_REGION=us-east
# export STREAM_DEV_KEY=u2db2meqxtuq
# export STREAM_DEV_SECRET=gjgdqrfaghqrw9c9mj2fbmbjhar2s2vs7gke9qpnp4a55u4vk9kdzpgrwfqxec8k
# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :streamex, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:streamex, :key)
#
# Or configure a 3rd-party app:
#
config :logger, level: :debug
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
