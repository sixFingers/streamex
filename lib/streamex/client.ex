defmodule Streamex.Client do
  use HTTPoison.Base

  @api_region Application.get_env(:streamex, :region)
  @api_key Application.get_env(:streamex, :key)
  @api_url "api.getstream.io/api/v1.0"

  def jwt_request(url, method, token, body \\ "", params \\ %{}) do
    request(
      method,
      api_url(url, params),
      body,
      request_headers(token),
      request_options()
    )
    |> parse_response
  end

  defp parse_response({:ok, response}) do
    {:ok, contents} = Poison.decode(response.body)
    contents
  end

  defp parse_response({:error, body}), do: {:error, body}

  defp api_url(url, params) when params == [] do
    "https://#{@api_region}-#{@api_url}/#{url}?api_key=#{@api_key}"
  end

  defp api_url(url, params) do
    <<api_url(url, []) :: binary, "&", URI.encode_query(params) :: binary>>
    # "https://#{@api_region}-#{@api_url}/#{url}?api_key=#{@api_key}&#{URI.encode_query(params)}"
  end

  defp request_headers(token) do
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
