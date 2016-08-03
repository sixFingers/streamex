defmodule ConfigTest do
  use ExUnit.Case
  doctest Streamex

  alias Streamex.Config

  setup_all do
    Config.configure("KEY", "SECRET", "eu-west")
  end

  test "client handles empty region" do
    Application.put_env(:streamex, :region, "")
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end
end
