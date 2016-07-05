defmodule Streamex.Token do
  import Joken

  @doc """
  Returns a valid token for * action, * resource,
  and the supplied feed slug and user_id
  """
  def new(client, slug, user_id) do
    base_token = %{resource: "*", action: "*", feed_id: "#{slug}#{user_id}"}
    |> token
    |> with_signer(hs256(client.secret))
    |> sign
    |> get_compact
  end
end
