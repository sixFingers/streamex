defmodule Streamex.Activities do
  import Streamex.Client
  alias Streamex.Feed, as: Feed
  alias Streamex.Activity, as: Activity

  def get(%Feed{} = feed, opts \\ []) do
    %Streamex.Request{}
    |> with_method(:get)
    |> with_path(endpoint_get(feed))
    |> with_token(feed, "feed", "read")
    |> with_params(activity_get_params(opts))
    |> execute
    |> handle_response
  end

  def add(%Feed{} = feed, %Activity{} = activity) do
    add(feed, [activity])
  end

  def add(%Feed{} = feed, [%Activity{} | _] = activities) do
    %Streamex.Request{}
    |> with_method(:post)
    |> with_path(endpoint_create(feed))
    |> with_token(feed, "feed", "write")
    |> with_body(Activity.to_json(activities))
    |> execute
    |> handle_response
  end

  def add_to_many(%Activity{} = activity, [_] = feeds) do
    %Streamex.Request{}
    |> with_method(:post)
    |> with_path(endpoint_add_to_many())
    |> with_body(body_create(feeds, activity))
    |> execute
    |> handle_response
  end

  def update(%Feed{} = feed, %Activity{} = activity) do
    update(feed, [activity])
  end

  def update(%Feed{} = feed, [%Activity{} | _] = activities) do
    %Streamex.Request{}
    |> with_method(:post)
    |> with_path(endpoint_update())
    |> with_token(feed, "activities", "write")
    |> with_body(Activity.to_json(activities))
    |> execute
    # we may append updated id here?
    |> handle_response
  end

  def remove(%Feed{} = feed, id, foreign_id \\ false) do
    params = foreign_id && %{"foreign_id" => 1} || %{}

    %Streamex.Request{}
    |> with_method(:delete)
    |> with_path(endpoint_remove(feed, id))
    |> with_token(feed, "feed", "delete")
    |> with_params(params)
    |> execute
    |> handle_response
  end

  defp activity_get_params(opts) do
    defaults = [limit: 25, offset: nil, id_gte: nil, id_gt: nil, id_lte: nil, id_lt: nil]
    Keyword.merge(defaults, opts) |> Enum.filter(fn({_, v}) -> v != nil end) |> Enum.into(%{})
  end

  # Error response
  # THIS SHOULD THROW EXCEPTION
  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  # Successful get response
  defp handle_response(%{"results" => results}) do
    Enum.map(results, &Activity.to_struct(&1))
  end

  # Successful add response
  defp handle_response(%{"activities" => results}) do
    Enum.map(results, &Activity.to_struct(&1))
  end

  # Successful update response
  defp handle_response(%{"duration" => _}) do
    {:ok, nil}
  end

  # Successful remove response
  defp handle_response(%{"removed" => id}) do
    {:ok, id}
  end

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

  defp body_create(feeds, activity) do
    payload = %{"feeds" => feeds, "activity" => activity}
    {:ok, body} = Poison.encode(payload)
    body
  end
end
