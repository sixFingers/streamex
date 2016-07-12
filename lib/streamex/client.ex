defmodule Streamex.Client do
  use HTTPoison.Base
  import Timex
  alias Timex.DateTime, as: DateTime
  alias Streamex.Request

  @api_region Application.get_env(:streamex, :region)
  @api_key Application.get_env(:streamex, :key)
  @api_secret Application.get_env(:streamex, :secret)
  @api_url "api.getstream.io/api/v1.0"

  def jwt_request(url, method, token, body \\ "", params \\ %{}) do
    request(
      method,
      api_url(url, params),
      body,
      jwt_request_headers(token),
      request_options()
    )
    |> parse_response
  end

  def signed_request(url, method, body \\ "", params \\ %{}) do
    algoritm = "hmac-sha256"
    {_, now} = DateTime.local() |> format("{RFC822}")
    api_key_header = {"X-Api-Key", @api_key}
    date_header = {"Date", now}
    content_type_header = {"content-type", "application/json"}

    headers_value = "date"
    header_field_string = "date: #{now}"
    signature = :crypto.hmac(:sha256, @api_secret, header_field_string) |> Base.encode64
    auth_header = {"Authorization", "Signature keyId=\"#{@api_key}\",algorithm=\"#{algoritm}\",headers=\"#{headers_value}\",signature=\"#{signature}\""}
    headers = [api_key_header, date_header, auth_header, content_type_header]

    request!(
      method,
      api_url(url, params),
      body,
      headers,
      request_options()
    )
  end

  defp parse_response({:ok, response}) do
    {:ok, contents} = Poison.decode(response.body)
    contents
  end

  defp parse_response({:error, body}), do: {:error, body}

  defp api_url(url, params) when params == %{} do
    "https://#{@api_region}-#{@api_url}/#{url}?api_key=#{@api_key}"
  end

  defp api_url(url, params) do
    <<api_url(url, %{}) :: binary, "&", URI.encode_query(params) :: binary>>
  end

  defp jwt_request_headers(token) do
    [
      {"Authorization", token},
      {"stream-auth-type", "jwt"},
      {"content-type", "application/json"}
    ]
  end

  defp request_options() do
    [{:timeout, 3000}]
  end
end
