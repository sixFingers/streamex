defmodule Streamex.Config do
  @api_url "api.getstream.io/api"

  def configure(key, secret, region \\ "", version \\ 1.0) do
    Application.put_env(:streamex, :key, key)
    Application.put_env(:streamex, :secret, secret)
    Application.put_env(:streamex, :region, region)
    Application.put_env(:streamex, :version, version)
  end

  def base_url do
    case region do
      "" -> "https://#{@api_url}/#{version}"
      _ -> "https://#{region}-#{@api_url}/#{version}"
    end
  end

  def key, do: Application.get_env(:streamex, :key)

  def secret, do: Application.get_env(:streamex, :secret)

  def region, do: Application.get_env(:streamex, :region)

  def version, do: Application.get_env(:streamex, :version)
end
