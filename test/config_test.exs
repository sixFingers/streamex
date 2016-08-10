defmodule ConfigTest do
  use ExUnit.Case, async: false
  alias Streamex.Config

  doctest Streamex

  test "Configuration handles empty region" do
    Config.configure(Config.key, Config.secret, region: "")
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end

  test "Configuration handles region" do
    Config.configure(Config.key, Config.secret, region: "us-west")
    assert Config.base_url == "https://us-west-api.getstream.io/api/1.0"
  end
end
