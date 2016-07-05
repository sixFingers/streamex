defmodule Streamex.Client do
  use HTTPoison.Base

  defstruct key: "", secret: "", base_url: ""

  @api_url "api.getstream.io/api/v1.0/"

  @doc """
  Returns a client with key, secret and api_url info.
  Every single call to API endpoints needs this struct.
  """
  def new(key, secret, region \\ "") do
    %__MODULE__{key: key, secret: secret, base_url: base_url(region)}
  end

  @doc """
  Performs the actual :get request underlying
  API read-only operations.
  """
  def jwt_request(client, token, url, method) do
    headers = do_jwt_auth_headers(token)
    full_url = do_process_url(client, url)
    request(method, full_url, "", headers, [])
  end

  defp base_url(region) do
    "https://#{region}-#{@api_url}"
  end

  defp do_process_url(client, url) do
    full_url = <<client.base_url :: binary, url :: binary>>
    do_append_querystring(client, full_url)
  end

  defp do_append_querystring(client, url) do
    <<url :: binary, "?", URI.encode_query(%{"api_key": client.key}) :: binary>>
  end

  defp do_jwt_auth_headers(token) do
    [
      {"Authorization", token},
      {"stream-auth-type", "jwt"}
    ]
  end
end
