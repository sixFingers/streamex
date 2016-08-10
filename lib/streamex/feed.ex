defmodule Streamex.Feed do
  @moduledoc """
  The `Streamex.Feed` module defines functions
  for working with feed followers.
  """

  import Streamex.Request
  alias Streamex.{Client, Request, Follow, ErrorInput}

  defstruct slug: nil, user_id: nil, id: nil

  @type t :: %__MODULE__{}

  @doc """
  Initializes a new feed.
  Both `slug` and `user_id` must contain only alphanumeric characters.
  Returns `{:ok, feed}`, or `{:error, message}` if feed is invalid.

  ## Examples

      iex > Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex > Streamex.Feed.new("user_", "eric")
      {:error, "..."}

  """
  def new(slug, user_id) do
    case validate([slug, user_id]) do
      true -> {:ok, %__MODULE__{slug: slug, user_id: user_id, id: "#{slug}#{user_id}"}}
      false -> {:error, ErrorInput.message}
    end
  end

  @doc """
  Lists the given feed's followers.
  Returns `{:ok, followers}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `limit` - limits the number of results. Defaults to `25`
    - `offset` - offsets the results. The maximum amount is `400`

  ## Examples

      iex> Feed.followers(feed)
      {:ok, [%Streamex.Follow{}...]}

  """
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

  @doc """
  Lists the feeds the given feed is following.
  Returns `{:ok, following}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `limit` - limits the number of results. Defaults to `25`
    - `offset` - offsets the results. The maximum amount is `400`
    - `filter` - list of comma separated feed ids to filter on

  ## Examples

      iex> Feed.following(feed)
      {:ok, [%Streamex.Follow{}...]}

  """
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

  @doc """
  Make `source` feed follow `target` feed.
  Returns `{:ok, nil}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `activity_copy_limit` - how many activities should be copied from the target feed. Defaults to `300`

  ## Examples

      iex> {_, source} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> {_, target} = Streamex.Feed.new("user", "jessica")
      {:ok, %Streamex.Feed{...}}

      iex> Feed.follow(source, target)
      {:ok, nil}

  """
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

  @doc """
  Make multiple sources follow multiple targets.
  Accepts a list of `{source, target}` feeds.
  Returns `{:ok, nil}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `activity_copy_limit` - how many activities should be copied from the target feed. Defaults to `100`

  ## Examples

      iex> {_, source} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> {_, target} = Streamex.Feed.new("user", "jessica")
      {:ok, %Streamex.Feed{...}}

      iex> Feed.follow_many([{source, target}, ...])
      {:ok, nil}

  """
  def follow_many(feeds, opts \\ []) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_create_following_many())
    |> with_body(body_create_following_many(feeds))
    |> with_params(params_create_following_many(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc """
  Stop `source` feed from following `target` feed.
  Returns `{:ok, nil}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `keep_history` - if `true` activities from `target` won't be removed from `source`

  ## Examples

      iex> {_, source} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> {_, target} = Streamex.Feed.new("user", "jessica")
      {:ok, %Streamex.Feed{...}}

      iex> Feed.unfollow(source, target)
      {:ok, nil}

  """
  def unfollow(source, target, opts \\ []) do
    Request.new
    |> with_method(:delete)
    |> with_path(endpoint_remove_following(source, target))
    |> with_params(params_remove_following(opts))
    |> with_token(source, "follower", "delete")
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc false
  def get_follow_target_string(feed) do
    "#{feed.slug}:#{feed.user_id}"
  end

  @doc false
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

  defp params_remove_following(opts) do
    keep_history = Keyword.get(opts, :keep_history, false)
    keep_history && %{"keep_history" => "true"} || %{}
  end

  defp params_create_following_many(opts) do
    defaults = [activity_copy_limit: 300]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  defp body_create_following(feed) do
    Poison.encode!(%{"target" => get_follow_target_string(feed)})
  end

  defp body_create_following_many(feeds) do
    feeds = Enum.map(feeds, fn({source, target}) ->
      %{
        "source" => get_follow_target_string(source),
        "target" => get_follow_target_string(target)
      }
    end)

    Poison.encode!(feeds)
  end
end
