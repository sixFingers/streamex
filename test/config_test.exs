defmodule ConfigTest do
  use ExUnit.Case
  alias Streamex.Config

  doctest Streamex

  test "Configure with values from environment and no region" do
    Config.configure()
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end
end
