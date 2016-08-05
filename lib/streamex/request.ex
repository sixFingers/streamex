defmodule Streamex.Request do
  alias Streamex.{Config, Token}

  @default_headers [
    {"content-type", "application/json"}
  ]

  defstruct [
    url: "",
    path: "",
    method: :get,
    headers: @default_headers,
    params: %{},
    body: "",
    options: [],
    token: nil
  ]

  @type t :: %__MODULE__{}

  @spec new() :: __MODULE__.t
  def new do
    struct(%__MODULE__{options: default_options})
  end

  @spec with_method(__MODULE__.t, atom) :: __MODULE__.t
  def with_method(%__MODULE__{} = r, method) do
    %{r | method: method}
  end

  @spec with_path(__MODULE__.t, String.t) :: __MODULE__.t
  def with_path(%__MODULE__{} = r, path) do
    %{r | path: path}
  end

  @spec with_body(__MODULE__.t, String.t) :: __MODULE__.t
  def with_body(%__MODULE__{} = r, body) do
    %{r | body: body}
  end

  @spec with_token(__MODULE__.t, String.t, String.t, String.t) :: __MODULE__.t
  def with_token(%__MODULE__{} = r, feed, resource, action) do
    %{r | token: %Token{feed_id: feed.id, resource: resource, action: action}}
  end

  @spec with_params(__MODULE__.t, %{}) :: __MODULE__.t
  def with_params(%__MODULE__{} = r, params) do
    %{r | params: params}
  end

  defp default_options do
    [
      {:timeout, Config.timeout}
    ]
  end
end
