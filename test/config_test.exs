defmodule ConfigTest do
  use ExUnit.Case, async: false
  alias Streamex.Config

  doctest Streamex

  test "Configuration handles empty region" do
    Application.put_env(:streamex, :region, "")
    assert Config.base_url == "https://api.stream-io-api.com/api/v1.0"
  end

  test "Configuration handles region" do
    Application.put_env(:streamex, :region, "us-west")
    assert Config.base_url == "https://us-west-api.stream-io-api.com/api/v1.0"
  end
end
