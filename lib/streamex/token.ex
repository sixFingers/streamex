defmodule Streamex.Token do
  @moduledoc """
  The `Streamex.Token` module is responsible for JWT Token generation.
  It's not meant to be used directly, although functions are
  publicly available in case of need.
  """

  import Joken

  defstruct resource: "", action: "", feed_id: ""

  @type t :: %__MODULE__{}

  @doc """
  Generates a compact token, with grants for given `Streamex.Token`'s' `resource`, `action` and `feed_id`,
  and signs it with `secret`.
  """
  def compact(%__MODULE__{} = token, secret) do
    %{resource: token.resource, action: token.action, feed_id: token.feed_id}
    |> token
    |> with_signer(hs256(secret))
    |> sign
    |> get_compact
  end
end
