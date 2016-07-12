defmodule Streamex.Request do
  import Timex
  alias Timex.DateTime, as: DateTime

  @default_options [
    {:timeout, 3000}
  ]

  @default_headers [
    {"content-type", "application/json"}
  ]

  defstruct path: "",
            method: :get,
            headers: @default_headers,
            params: %{},
            body: "",
            options: @default_options,
            token: nil

  def sign(%__MODULE__{} = r) do
    headers = [
      {"Authorization", r.token},
      {"stream-auth-type", "jwt"},
    ] ++ r.headers
    r = %{r | headers: headers}
    r
  end

  def sign(%__MODULE__{} = r, key, secret) do
    algoritm = "hmac-sha256"
    {_, now} = DateTime.local() |> format("{RFC822}")

    api_key_header = {"X-Api-Key", key}
    date_header = {"Date", now}
    headers_value = "date"
    header_field_string = "#{headers_value}: #{now}"
    signature = :crypto.hmac(:sha256, secret, header_field_string) |> Base.encode64
    auth_header = {"Authorization", "Signature keyId=\"#{key}\",algorithm=\"#{algoritm}\",headers=\"#{headers_value}\",signature=\"#{signature}\""}

    headers = [api_key_header, date_header, auth_header] ++ r.headers
    r = %{r | headers: headers}
    r
  end
end
