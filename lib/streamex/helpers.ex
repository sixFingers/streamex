defmodule Streamex.Helpers do
  @spec validate([String.t, ...]) :: boolean
  def validate([string | t]) do
    case validate(string) do
      false -> false
      true -> validate(t)
    end
  end

  @spec validate([]) :: boolean
  def validate([]), do: true

  @spec validate(tuple()) :: boolean
  def validate({_, __} = t) do
    validate(Tuple.to_list(t))
  end

  @spec validate(String.t) :: boolean
  def validate(string) do
    !Regex.match?(~r/\W/, string)
  end

  @spec validate_error() :: {:error, String.t}
  def validate_error do
    {:error, "Invalid input"}
  end
end
