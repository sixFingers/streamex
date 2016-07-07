defmodule Streamex.Activity do
  defstruct actor: nil, verb: nil, object: nil, target: "", time: "", to: [], foreign_id: "", custom_fields: %{}

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
    struct = struct(%Streamex.Activity{})

    attrs
    |> Map.to_list
    |> Enum.reduce(struct, fn({k, v}, acc) ->
      atom = String.to_atom(k)
      case Map.has_key?(struct, atom) do
        true -> %{acc | atom => v}
        false -> %{acc | :custom_fields => Map.update(struct.custom_fields, k, v, &(&1))}
      end
    end)
  end
end
