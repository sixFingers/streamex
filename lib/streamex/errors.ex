defmodule Streamex.ErrorNotFound do
  @message "DoesNotExistException"

  defexception message: @message

  def message, do: @message
end

defmodule Streamex.ErrorFeedNotFound do
  @message "FeedConfigException"

  defexception message: @message

  def message, do: @message
end

defmodule Streamex.ErrorInput do
  @message "InputException"

  defexception message: @message

  def message, do: @message
end
