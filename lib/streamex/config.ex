defmodule Streamex.Config do
  @moduledoc """
  The `Streamex.Config` module defines functions
  for configuring the connection client.
  """

  @api_url "api.stream-io-api.com/api"
  @default_timeout 3000
  @default_version 1.0
  @default_region ""

  @doc """
  Returns the current client's base api url.
  """
  def base_url do
    case region do
      "" -> "https://#{@api_url}/v#{version}/"
      _ -> "https://#{region}-#{@api_url}/v#{version}/"
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
  def region, do: Application.get_env(:streamex, :region, @default_region)

  @doc """
  Returns the current client's api version.
  """
  def version, do: Application.get_env(:streamex, :version, @default_version)

  @doc """
  Returns the current client's timeout setting.
  """
  def timeout, do: Application.get_env(:streamex, :timeout)
end
