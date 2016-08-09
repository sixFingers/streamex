defmodule ClientTest do
  use ExUnit.Case, async: false
  alias Streamex.{Config, Request, Client}
  alias Joken

  doctest Streamex

  setup_all do
    Config.configure()
  end

  test "client builds requests with correct full url" do
    Application.put_env(:streamex, :region, "eu-west")
    req = %Request{} |> Request.with_params(%{"parameter" => "value"}) |> Client.prepare_request
    assert req.url == "https://eu-west-api.getstream.io/api/1.0?api_key=#{Config.key}&parameter=value"
  end

  test "client correctly signs request with token" do
    feed = %Streamex.Feed{slug: "user", user_id: "eric", id: "usereric"}

    req = %Request{}
    |> Request.with_token(feed, "feed", "read")
    |> Client.sign_request

    headers = req.headers
    |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.update(acc, k, v, &(&1)) end)

    token_string = Map.get(headers, "Authorization", nil)
    assert token_string !== nil

    assert Map.get(headers, "stream-auth-type", nil) == "jwt"

    token = token_string
    |> Joken.token
    |> Joken.with_signer(Joken.hs256(Config.secret))
    |> Joken.verify

    assert Map.get(token.claims, "resource", nil) == "feed"
    assert Map.get(token.claims, "action", nil) == "read"
    assert Map.get(token.claims, "feed_id", nil) == "usereric"
  end

  test "client correctly signs request with key/secret" do
    req = %Request{} |> Client.sign_request
    headers = req.headers |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.update(acc, k, v, &(&1)) end)
    date = Map.get(headers, "Date", "")
    header_field_string = "date: #{date}"
    signature = :crypto.hmac(:sha256, Config.secret, header_field_string) |> Base.encode64
    auth_header = "Signature keyId=\"#{Config.key}\",algorithm=\"hmac-sha256\",headers=\"date\",signature=\"#{signature}\""

    assert Map.get(headers, "X-Api-Key", "") == Config.key
    assert Map.get(headers, "Authorization", "") == auth_header
  end
end
