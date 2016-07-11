defmodule Streamex.Feed do
  import Streamex.Client
  alias Streamex.Follow, as: Follow

  defstruct slug: nil, user_id: nil, id: nil

  def new(slug, user_id) do
    %__MODULE__{slug: slug, user_id: user_id, id: "#{slug}#{user_id}"}
  end

  def followers(%__MODULE__{} = feed, opts \\ []) do
    defaults = [limit: 25, offset: 0]
    opts = Keyword.merge(defaults, opts)
    url = endpoint_get_followers(feed)
    token = Streamex.Token.new(feed, "follower", "read")

    jwt_request(url, :get, token, "", opts)
    |> handle_response
  end

  def following(%__MODULE__{} = feed, opts \\ []) do
    defaults = [limit: 25, offset: 0]
    opts = Keyword.merge(defaults, opts)
    url = endpoint_get_following(feed)
    token = Streamex.Token.new(feed, "follower", "read")

    jwt_request(url, :get, token, "", opts)
    |> handle_response
  end

  def follow(%__MODULE__{} = feed, target_feed, target_user, opts \\ []) do
    defaults = [activity_copy_limit: 300]
    opts = Keyword.merge(defaults, opts)
    url = endpoint_create_following(feed)
    token = Streamex.Token.new(feed, "follower", "write")
    target = get_follow_target_string(target_feed, target_user)
    {:ok, body} = Poison.encode(%{"target" => target})

    jwt_request(url, :post, token, body, opts)
    |> handle_response
  end

  def unfollow(%__MODULE__{} = feed, target_feed, target_user, opts \\ []) do
    target = get_follow_target_string(target_feed, target_user)
    url = endpoint_remove_following(feed, target)
    token = Streamex.Token.new(feed, "follower", "delete")

    jwt_request(url, :delete, token, "", opts)
    |> handle_response
  end

  defp get_follow_target_string(target_feed, target_user) do
    "#{target_feed}:#{target_user}"
  end

  # Error response
  # THIS SHOULD THROW EXCEPTION
  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  # Successful get response
  defp handle_response(%{"results" => results}) do
    results
    |> Enum.map(&Follow.to_struct(&1))
  end

  # Successful post response
  defp handle_response(_) do
    {:ok, nil}
  end

  defp endpoint_get_followers(%__MODULE__{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/followers/">>
  end

   defp endpoint_get_following(%__MODULE__{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/following/">>
  end

  defp endpoint_create_following(%__MODULE__{} = feed) do
    endpoint_get_following(feed)
  end

  defp endpoint_remove_following(%__MODULE__{} = feed, target) do
    <<endpoint_get_following(feed) :: binary, target :: binary, "/">>
  end
end
