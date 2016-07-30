defmodule Streamex.Feed do
  import Streamex.Client
  alias Streamex.Follow, as: Follow

  defstruct slug: nil, user_id: nil, id: nil

  def new(slug, user_id) do
    %__MODULE__{slug: slug, user_id: user_id, id: "#{slug}#{user_id}"}
  end

  def followers(%__MODULE__{} = feed, opts \\ []) do
    new_request
    |> with_method(:get)
    |> with_path(endpoint_get_followers(feed))
    |> with_token(feed, "follower", "read")
    |> with_params(params_get_followers(opts))
    |> execute
    |> handle_response
  end

  def following(%__MODULE__{} = feed, opts \\ []) do
    new_request
    |> with_method(:get)
    |> with_path(endpoint_get_following(feed))
    |> with_token(feed, "follower", "read")
    |> with_params(params_get_following(opts))
    |> execute
    |> handle_response
  end

  def follow(%__MODULE__{} = feed, target_feed, target_user, opts \\ []) do
    new_request
    |> with_method(:post)
    |> with_path(endpoint_create_following(feed))
    |> with_token(feed, "follower", "write")
    |> with_body(body_create_following(target_feed, target_user))
    |> with_params(params_create_following(opts))
    |> execute
    |> handle_response
  end

  def follow_many(followings, opts \\ []) do
    new_request
    |> with_method(:post)
    |> with_path(endpoint_create_following_many())
    |> with_body(body_create_following_many(followings))
    |> with_params(params_create_following_many(opts))
    |> execute
    |> handle_response
  end

  def unfollow(%__MODULE__{} = feed, target_feed, target_user, _) do
    target = get_follow_target_string(target_feed, target_user)

    new_request
    |> with_method(:delete)
    |> with_path(endpoint_remove_following(feed, target))
    |> with_token(feed, "follower", "delete")
    |> execute
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

  defp endpoint_create_following_many() do
    "follow_many/"
  end

  defp params_get_followers(opts) do
    defaults = [limit: 25, offset: 0]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  defp params_get_following(opts) do
    params_get_followers(opts)
  end

  defp params_create_following(opts) do
    defaults = [activity_copy_limit: 300]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  defp params_create_following_many(opts) do
    defaults = [activity_copy_limit: 300]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  defp body_create_following(target_feed, target_user) do
    target = get_follow_target_string(target_feed, target_user)
    {:ok, body} = Poison.encode(%{"target" => target})
    body
  end

  defp body_create_following_many(followings) do
    {:ok, body} = Poison.encode(followings)
    body
  end
end
