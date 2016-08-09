defmodule ConfigTest do
  use ExUnit.Case
  alias Streamex.Config

  doctest Streamex

  test "client handles empty region" do
    Application.put_env(:streamex, :region, "")
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end
end
