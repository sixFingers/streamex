defmodule Streamex.Activities do
  import Streamex.Client

  def get(client) do
    endpoint_activities(client)
    |> jwt_request(client, :get)
    |> handle_response
  end

  def create(%Streamex.Activity{} = activity, client) do
    create([activity], client)
  end

  def create([%Streamex.Activity{} | _] = activities, client) do
    url = endpoint_activities(client)
    {:ok, body} = encode_activities(activities)
    jwt_request(url, client, :post, body)
    |> handle_response
  end

  def remove(id, client, foreign_id \\ 0) do
    url = endpoint_feed_detail(id, client)
    jwt_request(url, client, :delete, "", %{"foreign_id" => foreign_id})
  end

  defp encode_activities(activities) do
    %{activities: Enum.map(activities, &encode_activity(&1))}
    |> Poison.encode
  end

  defp encode_activity(activity) do
    activity
    |> Streamex.Activity.to_map
  end

  defp handle_response(%{"activities" => results}) do
    Enum.map(results, &Streamex.Activity.to_struct(&1))
  end

  defp handle_response(%{"results" => results}) do
    Enum.map(results, &Streamex.Activity.to_struct(&1))
  end

  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  defp endpoint_activities(client) do
    <<"feed/", client.slug :: binary, "/", client.user_id :: binary, "/">>
  end

  defp endpoint_feed_detail(id, client) do
    <<"feed/", client.slug :: binary, "/", client.user_id :: binary, "/", id :: binary, "/">>
  end
end
