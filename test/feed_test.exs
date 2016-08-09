defmodule FeedTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Streamex.Helpers
  alias Streamex.{Feed, Config, Follow}

  doctest Streamex

  setup_all do
    Config.configure("9xup4y9pydw6", "jfw8xukqrp8axd2h5g22r67veys9qajz8aqkbsg25w3dhc6hsr737qb5wnqaywkz")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed initialization params get validated" do
    {status_a, _} = Feed.new("user:", "eric")
    {status_b, _} = Feed.new("user", ":eric")
    {status_c, _} = Feed.new("user", "eric")

    assert status_a == :error
    assert status_b == :error
    assert status_c == :ok
  end

  test "Feed follow request with invalid input returns error" do
    {_, feed} = Feed.new("user", "eric")

    assert Feed.follow(feed, "user:", "jessica") == validate_error
    assert Feed.follow(feed, "user", ":jessica") == validate_error
  end

  test "Feed follow request with valid input returns ok" do
    use_cassette "feed_post_follow" do
      {_, feed} = Feed.new("user", "eric")
      {status, _} = Feed.follow(feed, "user", "jessica")

      assert status == :ok
    end
  end

  test "Feed follow batch request with invalid input returns error" do
    mistyped_a = [{{"user:", "eric"}, {"user", "jessica"}}, {{"user", "eric"}, {"user", "deborah"}}]
    mistyped_b = [{{"user", "eric"}, {"user", "jessica"}}, {{"user", "eric"}, {"user", ":deborah"}}]

    assert Feed.follow_many(mistyped_a) == validate_error
    assert Feed.follow_many(mistyped_b) == validate_error
  end

  test "Feed follow batch request with valid input returns ok" do
    use_cassette "feed_post_batch_follow" do
      follows = [{{"user", "eric"}, {"user", "jessica"}}, {{"user", "eric"}, {"user", "deborah"}}]
      {status, _} = Feed.follow_many(follows)

      assert status == :ok
    end
  end

  test "Feed unfollow request with invalid input returns error" do
    {_, feed} = Feed.new("user", "eric")

    assert Feed.unfollow(feed, "user:", "jessica") == validate_error
    assert Feed.unfollow(feed, "user", ":jessica") == validate_error
  end

  test "Feed unfollow request with valid input returns ok" do
    use_cassette "feed_delete_follow" do
      {_, feed} = Feed.new("user", "eric")
      {status, _} = Feed.unfollow(feed, "user", "jessica")

      assert status == :ok
    end
  end

  test "Feed followers return a list of follow structs" do
    use_cassette "feed_get_followers" do
      {_, feed} = Feed.new("user", "eric")
      {__, followers} = Feed.followers(feed)

      assert Enum.count(followers) == 1
      assert %Follow{feed_id: "user:jessica"} = Enum.at(followers, 0)
    end
  end

  test "Feed followings return a list of follow structs" do
    use_cassette "feed_get_following" do
      {_, feed} = Feed.new("user", "eric")
      {__, following} = Feed.following(feed)

      assert Enum.count(following) == 2
    end
  end
end
