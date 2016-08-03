defmodule Streamex.Token do
  import Joken

  defstruct resource: "", action: "", feed_id: ""

  def compact(%__MODULE__{} = token, secret) do
    %{resource: token.resource, action: token.action, feed_id: token.feed_id}
    |> token
    |> with_signer(hs256(secret))
    |> sign
    |> get_compact
  end
end
