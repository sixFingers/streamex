defmodule Streamex.Activities do
  import Streamex.Request
  alias Streamex.{Request, Client, Feed, Activity}

  @spec get(Feed.t, []) :: {:ok, [Activity.t, ...]} | {:error, String.t}
  def get(%Feed{} = feed, opts \\ []) do
    Request.new
    |> with_method(:get)
    |> with_path(endpoint_get(feed))
    |> with_token(feed, "feed", "read")
    |> with_params(activity_get_params(opts))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> Client.parse_response
    |> handle_response
  end

  @spec add(Feed.t, Activity.t) :: {:ok, Activity.t} | {:error, String.t}
  def add(%Feed{} = feed, %Activity{} = activity) do
    {status, results} = add(feed, [activity])

    case status do
      :ok -> Enum.at(results, 0)
      :error -> {status, results}
    end
  end

  @spec add(Feed.t, [Activity.t, ...]) :: {:ok, [Activity.t, ...]} | {:error, String.t}
  def add(%Feed{} = feed, [%Activity{} | _] = activities) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_create(feed))
    |> with_token(feed, "feed", "write")
    |> with_body(Activity.to_json(activities))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> Client.parse_response
    |> handle_response
  end

  @spec add_to_many(Activity.t, [tuple(), ...]) :: {:ok, nil} | {:error, String.t}
  def add_to_many(%Activity{} = activity, feeds) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_add_to_many())
    |> with_body(body_create_activities(feeds, activity))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> Client.parse_response
    |> handle_response
  end

  @spec update(Feed.t, Activity.t) :: {:ok, nil} | {:error, String.t}
  def update(%Feed{} = feed, %Activity{} = activity) do
    update(feed, [activity])
  end

  @spec update(Feed.t, [Activity.t, ...]) :: {:ok, nil} | {:error, String.t}
  def update(%Feed{} = feed, [%Activity{} | _] = activities) do
    Request.new
    |> with_method(:post)
    |> with_path(endpoint_update())
    |> with_token(feed, "activities", "write")
    |> with_body(Activity.to_json(activities))
    |> Client.prepare_request
    |> Client.sign_request
    |> Client.execute_request
    |> Client.parse_response
    |> handle_response
  end

  @spec remove(Feed.t, String.t, boolean) :: {:ok, nil} | {:error, String.t}
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
    |> Client.parse_response
    |> handle_response
  end

  defp activity_get_params(opts) do
    defaults = [limit: 25, offset: 0]
    Keyword.merge(defaults, opts) |> Enum.into(%{})
  end

  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  defp handle_response(%{"results" => results}) do
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  end

  defp handle_response(%{"activities" => results}) do
    {:ok, Enum.map(results, &Activity.to_struct(&1))}
  end

  defp handle_response(%{"duration" => _}) do
    {:ok, nil}
  end

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

  defp body_create_activities(feeds, activity) do
    feeds = Enum.map(feeds, fn({slug, user_id}) -> "#{slug}:#{user_id}" end)
    payload = %{"feeds" => feeds, "activity" => activity}
    {:ok, body} = Poison.encode(payload)
    body
  end
end
