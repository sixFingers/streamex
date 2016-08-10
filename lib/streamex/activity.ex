defmodule Streamex.Activity do
  @moduledoc """
  The module `Streamex.Activity` contains logic to wrap
  raw API results into `Streamex.Activity` structs.
  Methods in the module `Streamex.Activities` must be called
  with `Maps`, but will return `Streamex.Activity` structs.

  GetStream activities submitted to the API must _always_
  contain the following fields:

    - `actor` - the actor performing the activity
    - `verb` - the verb of the activity
    - `object` - the object of the activity

  A number of other fields are normally present in GetStream
  responses and those are mapped to fields in `Streamex.Activity` structs.

  Any other _custom_ attributes may be present when submitting
  new activities; custom attributes will be set as keys
  of an activity's `custom_field` `Map`.

  ## Examples

  Valid activity:

  ```
  %{"actor" => "Tony", "verb" => "like", "object" => "Elixir"}
  ```

  Valid activity with custom field:

  ```
  %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "field" => "value"}
  # client will return..
  %Streamex.Activity{..., custom_fields: %{"field" => "value"}}
  ```

  Invalid activity, missing required fields:

  ```
  %{"actor" => "Tony", "object" => "Elixir"}
  ```

  """

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

  @doc """
  Converts a `Map` of attributes to a `Streamex.Activity` struct.
  """
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
