defmodule Streamex.Feed.Following do
  import Streamex.Client

  def get(%Streamex.Feed{} = feed, limit \\ 25, offset \\ 0) do
    url = endpoint_get_following(feed)
    token = Streamex.Token.new(feed, "follower", "read")

    jwt_request(url, :get, token, "", %{"limit" => limit, "offset" => offset})
    |> handle_response
  end

  def create(%Streamex.Feed{} = feed, %Streamex.Feed{} = target_feed) do
    url = endpoint_create_following(feed)
    token = Streamex.Token.new(feed, "follower", "write")
    {:ok, body} = Poison.encode(%{"target" => "#{target_feed.slug}:#{target_feed.user_id}"})

    jwt_request(url, :post, token, body)
    |> handle_response
  end

  def remove(%Streamex.Feed{} = feed, %Streamex.Feed{} = target_feed) do
    url = endpoint_remove_following(feed, target_feed)
    token = Streamex.Token.new(feed, "follower", "write")

    jwt_request(url, :delete, token)
    |> handle_response
  end

  # Response from get request
  defp handle_response(%{"results" => results}) do
    results
  end

  # Response from create request
  defp handle_response(%{"duration" => _}) do
    :ok
  end

  # Error from create request
  defp handle_response(%{"detail" => detail}) do
    {:error, detail}
  end

  defp endpoint_get_following(%Streamex.Feed{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/following/">>
  end

  defp endpoint_create_following(%Streamex.Feed{} = feed) do
    endpoint_get_following(%Streamex.Feed{} = feed)
  end

  defp endpoint_remove_following(%Streamex.Feed{} = feed, %Streamex.Feed{} = target_feed) do
    <<endpoint_get_following(%Streamex.Feed{} = feed) :: binary, "#{target_feed.slug}:#{target_feed.user_id}/">>
  end
end
