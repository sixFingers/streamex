defmodule Streamex.Activities do
  @moduledoc """
  The `Streamex.Activities` module defines functions
  for working with feed activities.
  """

  import Streamex.Request
  alias Streamex.{Request, Client, Feed, Activity}

  @doc """
  Lists the given feed's activities.
  Returns `{:ok, activities}`, or `{:error, message}` if something went wrong.

  Available options are:

    - `limit` - limits the number of results. Defaults to `25`
    - `offset` - offsets the results
    - `id_gte` - filter the feed on ids greater than or equal to the given value
    - `id_gt` - filter the feed on ids greater than the given value
    - `id_lte` - filter the feed on ids smaller than or equal to the given value
    - `id_lt` - filter the feed on ids smaller than the given value

  ## Examples

      iex> {_, feed} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> Streamex.Activities.get(feed)
      {:ok, [%Streamex.Activity{}...]}

  """
  def get(feed, opts \\ []) do
    Request.new
    |> with_method(:get)
    |> with_path(endpoint_get(feed))
    |> with_token(feed, "feed", "read")
    |> with_params(activity_get_params(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc """
  Adds activities to the given feed.
  Accepts a single `Map` or a `List` of `Map`s.
  Returns `{:ok, activity | activities}`, or `{:error, message}`
  if something went wrong.
  Activities have a number of required fields.
  Refer to `Streamex.Activity` for a complete list.

  ## Examples

      iex> {_, feed} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:1"}
      %{...}

      iex> Streamex.Activities.add(feed, activity)
      {:ok, %Streamex.Activity{...}}

      iex> activity_b = %{"actor" => "Anna", "verb" => "like", "object" => "Hiking", "foreign_id" => "anna:1"}
      %{...}

      iex> Streamex.Activities.add(feed, [activity, activity_b])
      {:ok, [%Streamex.Activity{...}, %Streamex.Activity{...}]}

  """
  def add(feed, %{} = activity) do
    {status, results} = add(feed, [activity])

    case status do
      :ok -> {status, Enum.at(results, 0)}
      :error -> {status, results}
    end
  end
  def add(feed, [%{} | _] = activities) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_create(feed))
    |> with_token(feed, "feed", "write")
    |> with_body(body_create_update_activities(activities))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc """
  Adds an activity to a `List` of feeds.
  Returns `{:ok, nil}`, or `{:error, message}` if something went wrong.
  Activities have a number of required fields.
  Refer to `Streamex.Activity` for a complete list.

  ## Examples

      iex> {_, feed} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> {_, feed_b} = Streamex.Feed.new("user", "deborah")
      {:ok, %Streamex.Feed{...}}

      iex> activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:1"}
      %{...}

      iex> Streamex.Activities.add_to_many([feed, feed_b], activity)
      {:ok, nil}

  """
  def add_to_many(feeds, %{} = activity) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_add_to_many())
    |> with_body(body_create_batch_activities(feeds, activity))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc """
  Updates activities. Accepts a single `Map` or a `List` of `Map`s.
  Returns `{:ok, nil}`, or `{:error, message}`
  Activities have a number of required fields.
  Refer to `Streamex.Activity` for a complete list.

  ## Examples

      iex> {_, feed} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:1", "time" => "2016-08-09T19:38:12.241758"}
      %{...}

      iex> Streamex.Activities.update(feed, activity)
      {:ok, nil}

  """
  def update(feed, activity) when is_map(activity) do
    update(feed, [activity])
  end
  def update(feed, activities) when is_list(activities) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_update())
    |> with_token(feed, "activities", "write")
    |> with_body(body_create_update_activities(activities))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  @doc """
  Removes activities.
  Accepts an `id` or `foreign_id` string value.
  Returns `{:ok, removed_id}`, or `{:error, message}`

  Available options are:

    - `foreign_id` - if set to true, removes the activity by `foreign_id`

  ## Examples

      iex> {_, feed} = Streamex.Feed.new("user", "eric")
      {:ok, %Streamex.Feed{...}}

      iex> Streamex.Activities.remove(feed, "d2d6fc2c-5e5a-11e6-8080-80017383369d")
      {:ok, "d2d6fc2c-5e5a-11e6-8080-80017383369d"}

      iex> Streamex.Activities.remove(feed, "tony:1", foreign_id: true)
      {:ok, "tony:1"}

  """
  def remove(feed, id, opts \\ []) do
    foreign_id = Keyword.get(opts, :foreign_id, false)
    params = foreign_id && %{"foreign_id" => 1} || %{}

    Request.new
    |> with_method(:delete)
    |> with_path(endpoint_remove(feed, id))
    |> with_token(feed, "feed", "delete")
    |> with_params(params)
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  defp activity_get_params(opts) do
    defaults = [limit: 25, offset: 0]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  def handle_response(%{"exception" => exception}), do: {:error, exception}
  def handle_response(%{"results" => results}), do:
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  def handle_response(%{"activities" => results}), do:
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  def handle_response(%{"removed" => id}), do: {:ok, id}
  def handle_response(%{"duration" => _}), do: {:ok, nil}

  defp endpoint_get(%Feed{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/">>
  end

  defp endpoint_create(%Feed{} = feed) do
    endpoint_get(feed)
  end

  defp endpoint_update(), do: "activities/"

  defp endpoint_remove(%Feed{} = feed, id) do
    <<endpoint_get(feed) :: binary, id :: binary, "/">>
  end

  defp endpoint_add_to_many() do
    "feed/add_to_many/"
  end

  defp body_create_batch_activities(feeds, activity) do
    feeds = Enum.map(feeds, fn(feed) -> Feed.get_follow_target_string(feed) end)
    payload = %{"feeds" => feeds, "activity" => activity}
    Poison.encode!(payload)
  end

  defp body_create_update_activities(activities) do
    Poison.encode!(%{"activities" => activities})
  end
end
