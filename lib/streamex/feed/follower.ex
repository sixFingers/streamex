defmodule Streamex.Feed.Follower do
  defstruct feed_id: nil, target_id: nil, created_at: nil, updated_at: nil

  def to_struct(%{} = attrs) do
    struct = struct(%__MODULE__{})

    Enum.reduce Map.to_list(attrs), struct, fn {k, v}, acc ->
      %{acc | String.to_atom(k) => v}
    end
  end
end
