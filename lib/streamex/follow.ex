defmodule Streamex.Follow do
  defstruct feed_id: nil,
            target_id: nil,
            created_at: nil,
            updated_at: nil

  @type t :: %__MODULE__{}
end
