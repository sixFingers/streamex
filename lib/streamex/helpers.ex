defmodule Streamex.Helpers do
  def validate([string | t]) do
    case validate(string) do
      false -> false
      true -> validate(t)
    end
  end

  def validate([]), do: true

  def validate({_, __} = t) do
    validate(Tuple.to_list(t))
  end

  def validate(string) do
    !Regex.match?(~r/\W/, string)
  end

  def validate_error do
    {:error, "Invalid input"}
  end
end
