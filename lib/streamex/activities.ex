defmodule Streamex.Activities do
  import Streamex.Client

  def all(client) do
    endpoint_activities_all(client)
    |> jwt_request(client, :get)
  end

  defp endpoint_activities_all(client) do
    <<"feed/", client.slug :: binary, "/", client.user_id :: binary, "/">>
  end
end
