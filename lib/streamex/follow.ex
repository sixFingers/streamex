defmodule Streamex.Follow do
  defstruct feed_id: nil,
            target_id: nil,
            created_at: nil,
            updated_at: nil

  @type t :: %__MODULE__{}

  @spec to_struct(%{}) :: __MODULE__.t
  def to_struct(%{} = attrs) do
    attrs
    |> Map.to_list
    |> Enum.reduce(struct(%__MODULE__{}), fn({k, v}, acc) ->
      %{acc | String.to_atom(k) => v}
    end)
  end

  @spec to_json(__MODULE__.t) :: %{}
  def to_json(%__MODULE__{} = follow) do
    {:ok, body} = Poison.encode(follow)
    body
  end
end
