defmodule FeedTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Streamex.Feed
  import Streamex.Helpers
  alias Streamex.{Config, Follow}

  doctest Streamex

  setup_all do
    Config.configure("9xup4y9pydw6", "jfw8xukqrp8axd2h5g22r67veys9qajz8aqkbsg25w3dhc6hsr737qb5wnqaywkz")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed initialization params get validated" do
    {status_a, _} = new("user:", "eric")
    {status_b, _} = new("user", ":eric")
    {status_c, _} = new("user", "eric")

    assert status_a == :error
    assert status_b == :error
    assert status_c == :ok
  end

  test "Feed follow request validates input" do
    {_, feed} = new("user", "eric")

    assert follow(feed, "user:", "jessica") == validate_error
    assert follow(feed, "user", ":jessica") == validate_error
  end

  test "Feed follow batch request validates input" do
    mistyped_a = [{{"user:", "eric"}, {"user", "jessica"}}, {{"user", "eric"}, {"user", "deborah"}}]
    mistyped_b = [{{"user", "eric"}, {"user", "jessica"}}, {{"user", "eric"}, {"user", ":deborah"}}]

    assert follow_many(mistyped_a) == validate_error
    assert follow_many(mistyped_b) == validate_error
  end

  test "Feed unfollow request validates input" do
    {_, feed} = new("user", "eric")

    assert unfollow(feed, "user:", "jessica") == validate_error
    assert unfollow(feed, "user", ":jessica") == validate_error
  end

  test "Feed followers return a list of follow structs" do
    use_cassette "feed_get_followers" do
      {_, feed} = new("user", "eric")
      followers = Streamex.Feed.followers(feed)

      assert Enum.count(followers) == 1
      assert %Follow{feed_id: "user:jessica"} = Enum.at(followers, 0)
    end
  end

  test "Feed followings return a list of follow structs" do
    use_cassette "feed_get_following" do
      {_, feed} = new("user", "eric")
      following = Streamex.Feed.following(feed)

      assert Enum.count(following) == 2
    end
  end
end
