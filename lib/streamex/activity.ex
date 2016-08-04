defmodule Streamex.Activity do
  defstruct id: nil,
            foreign_id: nil,
            actor: nil,
            verb: nil,
            object: nil,
            time: nil,
            to: [],
            origin: nil,
            target: nil,
            custom_fields: %{}

  @doc """
  Initializes an Activity struct from supplied fields
  """
  def new(actor, verb, object, optional \\ [], custom \\ %{}) do
    struct = %__MODULE__{actor: actor, verb: verb, object: object, custom_fields: custom}
    optional = optional_fields(optional)

    Enum.reduce(optional, struct, fn({k, v}, acc) ->
      %{acc | k => v}
    end)
  end

  defp optional_fields(optional) do
    defaults = [target: nil, time: nil, to: nil, foreign_id: nil]

    Enum.filter_map(optional, fn({k, _}) -> Keyword.has_key?(defaults, k) end, &(&1))
    |> Enum.filter(fn({_, v}) -> v !== nil end)
  end

  @doc """
  Flattens an Activity struct into a plain map
  """
  def to_map(%__MODULE__{} = activity) do
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
    {standard, custom} = Map.split(attrs, Enum.map(Map.keys(%__MODULE__{}), &(Atom.to_string(&1))))
    custom_fields = if custom == nil, do: %{}, else: custom
    struct = struct(%__MODULE__{custom_fields: custom_fields})

    Enum.reduce Map.to_list(standard), struct, fn {k, v}, acc ->
      %{acc | String.to_atom(k) => v}
    end
  end

  def to_json([%__MODULE__{} | _] = activities) do
    {:ok, body} = %{activities: Enum.map(activities, &to_json(&1))}
    |> Poison.encode

    body
  end

  def to_json(%__MODULE__{} = activity) do
    {:ok, body} = Poison.encode(to_map(activity))

    body
  end
end
