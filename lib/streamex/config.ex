defmodule Streamex.Config do
  @api_url "api.getstream.io/api"

  def configure(key, secret, opts \\ []) do
    Application.put_env(:streamex, :key, key)
    Application.put_env(:streamex, :secret, secret)

    region = Keyword.get(opts, :region, "")
    Application.put_env(:streamex, :region, region)

    timeout = Keyword.get(opts, :timeout, 3000)
    Application.put_env(:streamex, :timeout, timeout)

    version = Keyword.get(opts, :version, 1.0)
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

  def timeout, do: Application.get_env(:streamex, :timeout)
end
