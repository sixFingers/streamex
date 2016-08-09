defmodule Streamex.Activities do
  import Streamex.Request
  alias Streamex.{Request, Client, Feed, Activity}

  def get(%Feed{} = feed, opts \\ []) do
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

  def add(%Feed{} = feed, %{} = activity) do
    {status, results} = add(feed, [activity])

    case status do
      :ok -> {status, Enum.at(results, 0)}
      :error -> {status, results}
    end
  end

  def add(%Feed{} = feed, [%{} | _] = activities) do
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

  def add_to_many(%{} = activity, feeds) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_add_to_many())
    |> with_body(body_create_batch_activities(feeds, activity))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> handle_response
  end

  def update(%Feed{} = feed, %{} = activity) do
    update(feed, [activity])
  end

  def update(%Feed{} = feed, [%{} | _] = activities) do
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

  def remove(%Feed{} = feed, id, foreign_id \\ false) do
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

  def handle_response(%{"results" => results}), do:
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  def handle_response(%{"activities" => results}), do:
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  def handle_response(%{"duration" => _}), do: {:ok, nil}
  def handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

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
