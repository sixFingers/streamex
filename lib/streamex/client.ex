defmodule Streamex.Client do
  @moduledoc """
  The `Streamex.Client` module is not meant to be used directly,
  although request-related functions are publicly available in case of need.
  """

  import HTTPoison, only: [request: 5]
  alias Streamex.{Request, Config, Token}

  @doc """
  Prepares a `Streamex.Request` for execution.
  Basically finalizes a request url.
  Returns a `Streamex.Request`.
  """
  def prepare_request(%Request{} = req) do
    uri = URI.merge(req.host, req.path)
    query = Map.merge(req.params, %{"api_key" => Config.key}) |> URI.encode_query
    uri = %{uri | query: query}
    %{req | url: to_string(uri)}
  end

  @doc """
  Signs a `Streamex.Request`.
  If token info are attached to the request, it will
  be signed with a JWT Token. Otherwise, with a server signature.
  Returns a `Streamex.Request`.
  """
  def sign_request(%Request{} = req) do
    case req.token do
      nil -> sign_request_with_key_secret(req, Config.key, Config.secret)
      _ -> sign_request_with_token(req, Config.secret)
    end
  end

  @doc """
  Executes a `Streamex.Request`.
  Returns {:ok, json}, or {:error, message} if something went wrong.
  """
  def execute_request(%Request{} = req) do
    request(req.method, req.url, req.body, req.headers, req.options)
    |> parse_response
  end

  @doc false
  def parse_response({:error, body}), do: {:error, body}
  def parse_response({:ok, %{} = r}), do: Poison.decode!(r.body)

  defp sign_request_with_token(%Request{} = req, secret) do
    token = Token.compact(req.token, secret)

    headers = [
      {"Authorization", token},
      {"stream-auth-type", "jwt"},
    ] ++ req.headers
    %{req | headers: headers}
  end

  defp sign_request_with_key_secret(%Request{} = req, key, secret) do
    algoritm = "hmac-sha256"
    {:ok, now} = Timex.now |> Timex.format("{RFC822}")

    api_key_header = {"X-Api-Key", key}
    date_header = {"Date", now}
    headers_value = "date"
    header_field_string = "#{headers_value}: #{now}"
    signature = :crypto.hmac(:sha256, secret, header_field_string) |> Base.encode64
    auth_header = {"Authorization", "Signature keyId=\"#{key}\",algorithm=\"#{algoritm}\",headers=\"#{headers_value}\",signature=\"#{signature}\""}

    headers = [api_key_header, date_header, auth_header] ++ req.headers
    %{req | headers: headers}
  end
end
