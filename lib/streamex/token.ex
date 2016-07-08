defmodule Streamex.Token do
  import Joken

  @api_secret Application.get_env(:streamex, :secret)

  def new(%Streamex.Feed{} = feed, resource, action) do
    %{resource: resource, action: action, feed_id: feed.id}
    |> token
    |> with_signer(hs256(@api_secret))
    |> sign
    |> get_compact
  end
end
