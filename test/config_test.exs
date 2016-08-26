defmodule ConfigTest do
  use ExUnit.Case, async: false
  alias Streamex.Config

  doctest Streamex

  test "Configuration handles empty region" do
    Application.put_env(:streamex, :region, "")
    assert Config.base_url == "https://api.getstream.io/api/1.0"
  end

  test "Configuration handles region" do
    Application.put_env(:streamex, :region, "us-west")
    assert Config.base_url == "https://us-west-api.getstream.io/api/1.0"
  end
end
