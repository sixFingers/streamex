defmodule Streamex.Activity do
  defstruct [
    :id,
    :foreign_id,
    :actor,
    :verb,
    :object,
    :time,
    :to,
    :origin,
    :target,
    custom_fields: %{}
  ]

  @type t :: %__MODULE__{}

  def to_struct(%{} = attrs) do
    {standard, custom} = Map.split(attrs, Enum.map(Map.keys(%__MODULE__{}), &(Atom.to_string(&1))))
    custom_fields = if custom == nil, do: %{}, else: custom
    struct = struct(%__MODULE__{custom_fields: custom_fields})

    Enum.reduce Map.to_list(standard), struct, fn {k, v}, acc ->
      %{acc | String.to_atom(k) => v}
    end
  end
end
