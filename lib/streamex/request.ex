defmodule Streamex.Request do
  @moduledoc """
  The `Streamex.Request` module wraps `Streamex.Client` requests.
  It's not meant to be used directly, although functions are
  publicly available in case of need.
  """

  alias Streamex.{Config, Token}

  @default_headers [
    {"content-type", "application/json"}
  ]

  defstruct url: "",
            path: "",
            method: :get,
            headers: @default_headers,
            params: %{},
            body: "",
            options: [],
            token: nil

  @type t :: %__MODULE__{}

  @doc """
  Initializes a `Streamex.Request` request.
  """
  def new do
    struct(%__MODULE__{options: default_options()})
  end

  @doc """
  Sets the `method` field of a `Streamex.Request`
  """
  def with_method(%__MODULE__{} = r, method) do
    %{r | method: method}
  end

  @doc """
  Sets the `path` field of a `Streamex.Request`
  """
  def with_path(%__MODULE__{} = r, path) do
    %{r | path: path}
  end

  @doc """
  Sets the `body` field of a `Streamex.Request`
  """
  def with_body(%__MODULE__{} = r, body) do
    %{r | body: body}
  end

  @doc """
  Attaches a `Streamex.Token` to a `Streamex.Request`
  """
  def with_token(%__MODULE__{} = r, feed, resource, action) do
    %{r | token: %Token{feed_id: feed.id, resource: resource, action: action}}
  end

  @doc """
  Sets the `params` field of a `Streamex.Request`
  """
  def with_params(%__MODULE__{} = r, params) do
    %{r | params: params}
  end

  defp default_options do
    [
      {:timeout, Config.timeout()}
    ]
  end
end
