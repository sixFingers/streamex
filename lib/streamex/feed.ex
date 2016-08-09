defmodule Streamex.Feed do
  import Streamex.Request
  alias Streamex.{Client, Request, Follow, ErrorInput}

  defstruct slug: nil, user_id: nil, id: nil

  @type t :: %__MODULE__{}

  def new(slug, user_id) do
    case validate([slug, user_id]) do
      true -> {:ok, %__MODULE__{slug: slug, user_id: user_id, id: "#{slug}#{user_id}"}}
      false -> {:error, ErrorInput.message}
    end
  end

  def followers(feed, opts \\ []) do
    Request.new
    |> with_method(:get)
    |> with_path(endpoint_get_followers(feed))
    |> with_token(feed, "follower", "read")
    |> with_params(params_get_followers(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def following(feed, opts \\ []) do
    Request.new
    |> with_method(:get)
    |> with_path(endpoint_get_following(feed))
    |> with_token(feed, "follower", "read")
    |> with_params(params_get_following(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def follow(source, target, opts \\ []) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_create_following(source))
    |> with_token(source, "follower", "write")
    |> with_body(body_create_following(target))
    |> with_params(params_create_following(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def follow_many(followings, opts \\ []) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_create_following_many())
    |> with_body(body_create_following_many(followings))
    |> with_params(params_create_following_many(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def unfollow(source, target) do
    Request.new
    |> with_method(:delete)
    |> with_path(endpoint_remove_following(source, target))
    |> with_token(source, "follower", "delete")
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def get_follow_target_string(feed) do
    "#{feed.slug}:#{feed.user_id}"
  end

  def handle_response(%{"exception" => exception}), do: {:error, exception}
  def handle_response(%{"results" => results}), do:
    {:ok, Enum.map(results, &Poison.Decode.decode(&1, as: %Follow{}))}
  def handle_response(%{"duration" => _}), do: {:ok, nil}

  defp validate([string | t]), do: validate(string) && validate(t)
  defp validate([]), do: true
  defp validate(string), do: !Regex.match?(~r/\W/, string)

  defp endpoint_get_followers(feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/followers/">>
  end

  defp endpoint_get_following(feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/following/">>
  end

  defp endpoint_create_following(feed) do
    endpoint_get_following(feed)
  end

  defp endpoint_remove_following(source_feed, target_feed) do
    <<endpoint_get_following(source_feed) :: binary, get_follow_target_string(target_feed) :: binary, "/">>
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

  defp body_create_following(feed) do
    Poison.encode!(%{"target" => get_follow_target_string(feed)})
  end

  defp body_create_following_many(followings) do
    followings = Enum.map(followings, fn({source, target}) ->
      %{
        "source" => get_follow_target_string(source),
        "target" => get_follow_target_string(target)
      }
    end)

    Poison.encode!(followings)
  end
end
