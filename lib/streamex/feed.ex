defmodule Streamex.Feed do
  import Streamex.Client

  defstruct slug: nil, user_id: nil, id: nil

  def new(slug, user_id) do
    %__MODULE__{slug: slug, user_id: user_id, id: "#{slug}#{user_id}"}
  end

  def get(%__MODULE__{} = feed) do
    url = endpoint_get_activities(feed)
    token = Streamex.Token.new(feed, "feed", "read")

    jwt_request(url, :get, token)
    |> handle_response
  end

  def create(%__MODULE__{} = feed, %Streamex.Feed.Activity{} = activity) do
    create(feed, [activity])
  end

  def create(%__MODULE__{} = feed, [%Streamex.Feed.Activity{} | _] = activities) do
    url = endpoint_create_activities(feed)
    token = Streamex.Token.new(feed, "feed", "write")
    {:ok, body} = Streamex.Feed.Activity.to_json(activities)

    jwt_request(url, :post, token, body)
    |> handle_response
  end

  def update(%__MODULE__{} = feed, %Streamex.Feed.Activity{} = activity) do
    update(feed, [activity])
  end

  def update(%__MODULE__{} = feed, [%Streamex.Feed.Activity{} | _] = activities) do
    url = endpoint_update_activities()
    token = Streamex.Token.new(feed, "activities", "write")
    {:ok, body} = Streamex.Feed.Activity.to_json(activities)

    jwt_request(url, :post, token, body)
    |> handle_response
  end

  def remove(%__MODULE__{} = feed, id, foreign_id \\ false) do
    url = endpoint_remove_activities(feed, id)
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

  # defp do_remove(url, token, foreign_id) when foreign_id == true do
  #   jwt_request(url, :delete, token, "", %{"foreign_id" => 1})
  # end

  # Response from get request
  defp handle_response(%{"results" => results}) do
    Enum.map(results, &Streamex.Feed.Activity.to_struct(&1))
  end

  # Response from create request
  defp handle_response(%{"activities" => results}) do
    Enum.map(results, &Streamex.Feed.Activity.to_struct(&1))
  end

  # Response from update requests
  defp handle_response(%{"duration" => _}) do
    {:ok, nil}
  end

  # Response with error
  defp handle_response(%{"status_code" => _, "detail" => detail}), do: {:error, detail}

  defp endpoint_get_activities(%__MODULE__{} = feed) do
    <<"feed/", feed.slug :: binary, "/", feed.user_id :: binary, "/">>
  end

  defp endpoint_create_activities(%__MODULE__{} = feed) do
    endpoint_get_activities(feed)
  end

  defp endpoint_update_activities() do
    "activities/"
  end

  defp endpoint_remove_activities(%__MODULE__{} = feed, id) do
    <<endpoint_get_activities(feed) :: binary, id :: binary, "/">>
  end
end
