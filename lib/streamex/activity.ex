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
    Enum.reduce(attrs, %__MODULE__{}, fn({key, value}, struct) ->
      atom = String.to_atom(key)

      if Map.has_key?(struct, atom) do
        Map.put(struct, atom, value)
      else
        custom_fields = Map.put(struct.custom_fields, key, value)
        %{struct | custom_fields: custom_fields}
      end
    end)
  end
end
