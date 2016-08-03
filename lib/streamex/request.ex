defmodule Streamex.Request do
  alias Streamex.Token

  @default_options [
    {:timeout, 3000}
  ]

  @default_headers [
    {"content-type", "application/json"}
  ]

  defstruct url: "",
            path: "",
            method: :get,
            headers: @default_headers,
            params: %{},
            body: "",
            options: @default_options,
            token: nil

  def with_method(%__MODULE__{} = r, method) do
    %{r | method: method}
  end

  def with_path(%__MODULE__{} = r, path) do
    %{r | path: path}
  end

  def with_body(%__MODULE__{} = r, body) do
    %{r | body: body}
  end

  def with_token(%__MODULE__{} = r, feed, resource, action) do
    %{r | token: %Token{feed_id: feed.id, resource: resource, action: action}}
  end

  def with_params(%__MODULE__{} = r, params) do
    %{r | params: params}
  end
end
