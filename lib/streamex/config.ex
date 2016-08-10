defmodule Streamex.Config do
  @moduledoc """
  The `Streamex.Config` module defines functions
  for configuring the connection client.
  """

  @api_url "api.getstream.io/api"
  @default_timeout 3000
  @default_version 1.0
  @default_region ""

  @doc """
  Configures the client with the values set in the
  configuration file. Returns `:ok`.
  """
  def configure() do
    configure(
      Application.get_env(:streamex, :key, ""),
      Application.get_env(:streamex, :secret, ""),
      region: Application.get_env(:streamex, :region, "")
    )
  end

  @doc """
  Configures the client with the specified `key`,
  `secret` and `options`. Returns `:ok`.

  Available options are:

    - `region` - Currently supported values are `us-east`, `us-west` and `eu-west`
    - `timeout` - Number of milliseconds before a request is discarded. `3000` by default
    - `version` - API version number. Defaults to 1.0

  ## Examples

      iex> Streamex.Config.configure("my_key", "my_secret")
      :ok

      iex> Streamex.Config.configure("my_key", [region: "us-central"])
      :ok

  """
  def configure(key, secret, opts \\ []) do
    Application.put_env(:streamex, :key, key)
    Application.put_env(:streamex, :secret, secret)

    region = Keyword.get(opts, :region, @default_region)
    Application.put_env(:streamex, :region, region)

    timeout = Keyword.get(opts, :timeout, @default_timeout)
    Application.put_env(:streamex, :timeout, timeout)

    version = Keyword.get(opts, :version, @default_version)
    Application.put_env(:streamex, :version, version)
  end

  @doc """
  Returns the current client's base api url.
  """
  def base_url do
    case region do
      "" -> "https://#{@api_url}/#{version}"
      _ -> "https://#{region}-#{@api_url}/#{version}"
    end
  end

  @doc """
  Returns the current client's api key.
  """
  def key, do: Application.get_env(:streamex, :key)

  @doc """
  Returns the current client's api secret.
  """
  def secret, do: Application.get_env(:streamex, :secret)

  @doc """
  Returns the current client's api region.
  """
  def region, do: Application.get_env(:streamex, :region)

  @doc """
  Returns the current client's api version.
  """
  def version, do: Application.get_env(:streamex, :version)

  @doc """
  Returns the current client's timeout setting.
  """
  def timeout, do: Application.get_env(:streamex, :timeout)
end
