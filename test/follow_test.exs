defmodule FollowTest do
  use ExUnit.Case, async: false
  alias Streamex.Follow

  doctest Streamex

  test "Follow struct get correctly converted to json" do
    struct = %Streamex.Follow{
      created_at: "2016-08-03T11:47:28.614Z",
      feed_id: "user:jessica",
      target_id: "user:eric",
      updated_at: "2016-08-03T11:47:28.614Z"
    }

    json = "{\"updated_at\":\"2016-08-03T11:47:28.614Z\",\"target_id\":\"user:eric\",\"feed_id\":\"user:jessica\",\"created_at\":\"2016-08-03T11:47:28.614Z\"}"

    assert Follow.to_json(struct) == json
  end
end
