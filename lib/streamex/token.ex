defmodule Streamex.Token do
  import Joken

  @api_secret Application.get_env(:streamex, :secret)

  def new(slug, user_id) do
    %{resource: "*", action: "*", feed_id: "#{slug}#{user_id}"}
    |> token
    |> with_signer(hs256(@api_secret))
    |> sign
    |> get_compact
  end
end
