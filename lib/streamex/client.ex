defmodule Streamex.Client do
  use HTTPoison.Base
  alias Streamex.Request

  @api_region Application.get_env(:streamex, :region)
  @api_key Application.get_env(:streamex, :key)
  @api_secret Application.get_env(:streamex, :secret)
  @api_url "api.getstream.io/api/v1.0"

  def with_method(%Request{} = r, method) do
    %{r | method: method}
  end

  def with_path(%Request{} = r, path) do
    %{r | path: path}
  end

  def with_body(%Request{} = r, body) do
    %{r | body: body}
  end

  def with_token(%Request{} = r, feed, resource, actions) do
    %{r | token: Streamex.Token.new(@api_secret, feed, resource, actions)}
  end

  def with_params(%Request{} = r, params) do
    %{r | params: params}
  end

  def execute(%Request{} = r) do
    case r.token do
      nil -> execute_signed(r)
      _ -> execute_jwt(r)
    end
  end

  defp execute_jwt(%Request{} = r) do
    r = Request.sign(r)

    request(
      r.method,
      full_url(r.path, r.params),
      r.body,
      r.headers,
      r.options
    )
    |> parse_response
  end

  defp execute_signed(%Request{} = r) do
    r = Request.sign(r, @api_key, @api_secret)

    request!(
      r.method,
      full_url(r.path, r.params),
      r.body,
      r.headers,
      r.options
    )
    |> parse_response
  end

  defp parse_response({:error, body}), do: {:error, body}

  defp parse_response({:ok, response}) do
    {:ok, contents} = Poison.decode(response.body)
    contents
  end

  defp parse_response(response) do
    {:ok, contents} = Poison.decode(response.body)
    contents
  end

  defp full_url(url, params) when params == %{} do
    "https://#{@api_region}-#{@api_url}/#{url}?api_key=#{@api_key}"
  end

  defp full_url(url, params) do
    <<full_url(url, %{}) :: binary, "&", URI.encode_query(params) :: binary>>
  end
end
