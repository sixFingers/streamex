defmodule Streamex.Activities do
  import Streamex.Client
  import Streamex.Helpers

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
  end

  defp encode_activities(activities) do
    %{activities: activities}
    |> Poison.encode
  end

  defp handle_response(%{"results" => results}) do
    Enum.map(results, fn(result) -> to_struct(%Streamex.Activity{}, result) end)
  end

  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  defp endpoint_activities(client) do
    <<"feed/", client.slug :: binary, "/", client.user_id :: binary, "/">>
  end
end
