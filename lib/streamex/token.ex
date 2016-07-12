defmodule Streamex.Token do
  import Joken

  def new(secret, %Streamex.Feed{} = feed, resource, action) do
    %{resource: resource, action: action, feed_id: feed.id}
    |> token
    |> with_signer(hs256(secret))
    |> sign
    |> get_compact
  end
end
