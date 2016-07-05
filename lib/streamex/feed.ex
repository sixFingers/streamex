defmodule Streamex.Feed do
  import Streamex.Client

  @doc """
  Read the whole feed for given slug and user_id
  """
  def all(client, slug, user_id) do
    url = <<"feed/", slug :: binary, "/", user_id :: binary, "/">>
    token = Streamex.Token.new(client, slug, user_id)
    jwt_request(client, token, url, :get)
  end
end
