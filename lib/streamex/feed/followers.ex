defmodule Streamex.Feed.Followers do
  import Streamex.Client

  def get(%Streamex.Feed{} = feed, limit \\ 25, offset \\ 0) do
    url = endpoint_get_followers(feed)
    token = Streamex.Token.new(feed, "follower", "read")

    jwt_request(url, :get, token, "", %{"limit" => limit, "offset" => offset})
    |> handle_response
  end

  # Response from get request
  defp handle_response(%{"results" => results}) do
    Enum.map(results, &Streamex.Feed.Follower.to_struct(&1))
  end

  defp endpoint_get_followers(%Streamex.Feed{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/followers/">>
  end
end
