defmodule Streamex.Activities do
  import Streamex.Client
  alias Streamex.Feed, as: Feed
  alias Streamex.Activity, as: Activity

  def get(%Feed{} = feed, opts \\ []) do
    url = endpoint_get(feed)
    token = Streamex.Token.new(feed, "feed", "read")
    params = activity_get_params(opts)

    jwt_request(url, :get, token, "", params)
    |> handle_response
  end

  def add(%Feed{} = feed, %Activity{} = activity) do
    add(feed, [activity])
  end

  def add(%Feed{} = feed, [%Activity{} | _] = activities) do
    url = endpoint_create(feed)
    token = Streamex.Token.new(feed, "feed", "write")
    body = Activity.to_json(activities)

    jwt_request(url, :post, token, body)
    |> handle_response
  end

  def update(%Feed{} = feed, %Activity{} = activity) do
    update(feed, [activity])
  end

  def update(%Feed{} = feed, [%Activity{} | _] = activities) do
    url = endpoint_update()
    token = Streamex.Token.new(feed, "activities", "write")
    body = Activity.to_json(activities)

    jwt_request(url, :post, token, body)
    |> handle_response
  end

  def remove(%Feed{} = feed, id, foreign_id \\ false) do
    url = endpoint_remove(feed, id)
    token = Streamex.Token.new(feed, "feed", "delete")

    do_remove(url, token, foreign_id)
    |> handle_response
  end

  defp do_remove(url, token, foreign_id) do
    case foreign_id do
      false -> jwt_request(url, :delete, token)
      true -> jwt_request(url, :delete, token, "", %{"foreign_id" => 1})
    end
  end

  defp activity_get_params(opts) do
    defaults = [limit: 25, offset: nil, id_gte: nil, id_gt: nil, id_lte: nil, id_lt: nil]
    Keyword.merge(defaults, opts) |> Enum.filter(fn({_, v}) -> v != nil end)
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
end
