defmodule ConfigTest do
  use ExUnit.Case
  alias Streamex.Config

  doctest Streamex

  setup_all do
    Config.configure()
  end

  test "Configure with values from environment and no region" do
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end
end
