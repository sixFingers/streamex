defmodule Streamex.Token do
  @moduledoc """
  The `Streamex.Token` module is responsible for JWT Token generation.
  It's not meant to be used directly, although functions are
  publicly available in case of need.
  """

  use Joken.Config
  alias Joken.Signer

  defstruct resource: "", action: "", feed_id: ""

  @type t :: %__MODULE__{}

  @doc """
  Generates a compact token, with grants for given `Streamex.Token`'s' `resource`, `action` and `feed_id`,
  and signs it with `secret`.
  """
  def compact(%__MODULE__{} = _token, secret) do
    {:ok, jwt, _} =
      generate_and_sign(
        %{"resource" => "*", "action" => "*", "feed_id" => "*"},
        Signer.create("HS256", secret)
      )

    jwt
  end

  def decompact(token, secret) do
    {:ok, claims} =
      verify_and_validate(
        token,
        Signer.create("HS256", secret)
      )

    claims
  end
end
