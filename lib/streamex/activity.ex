defmodule Streamex.Activity do
  defstruct id: nil,
            actor: nil,
            verb: nil,
            object: nil,
            target: nil,
            time: nil,
            to: [],
            foreign_id: nil,
            custom_fields: %{}

  @doc """
  Flattens an Activity struct into a plain map
  """
  def to_map(%Streamex.Activity{} = activity) do
    activity
    |> Map.to_list
    |> Enum.reduce([], fn({k, v}, acc) ->
      case k do
        :__struct__ -> acc
        :custom_fields -> acc ++ Map.to_list(v)
        :id -> acc
        _ -> [{k, v} | acc]
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Converts a map coming from the API into
  an Activity struct
  """
  def to_struct(%{} = attrs) do
    {standard, custom} = Map.split(attrs, Enum.map(Map.keys(%Streamex.Activity{}), &(Atom.to_string(&1))))
    struct = struct(%Streamex.Activity{custom_fields: custom})

    Enum.reduce Map.to_list(standard), struct, fn {k, v}, acc ->
      %{acc | String.to_atom(k) => v}
    end
  end
end
