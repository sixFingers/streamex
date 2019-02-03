defmodule Streamex.Follow do
  defstruct feed_id: nil,
            target_id: nil,
            created_at: nil,
            updated_at: nil

  @type t :: %__MODULE__{}

  defp to_datetime(datetime) do
    Timex.parse!(datetime, "{ISO:Extended:Z}")
  end

  def from_map(m) do
    base = struct(__MODULE__)
    base 
    |> Map.put(:feed_id, m["feed_id"])
    |> Map.put(:target_id, m["target_id"])
    |> Map.put(:created_at, to_datetime(m["created_at"]))
    |> Map.put(:updated_at, to_datetime(m["updated_at"]))
  end
end
