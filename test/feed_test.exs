defmodule FeedTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Streamex.{Feed, Follow, ErrorInput, ErrorFeedNotFound}

  doctest Streamex

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed initialization params get validated" do
    {status_a, error_a} = Feed.new("user:", "eric")
    {status_b, error_b} = Feed.new("user", ":eric")
    {status_c, _} = Feed.new("user", "eric")

    assert status_a == :error
    assert status_b == :error
    assert error_a == ErrorInput.message()
    assert error_b == ErrorInput.message()
    assert status_c == :ok
  end

  test "Feed follow request with invalid input returns error" do
    use_cassette "feed_post_follow_invalid" do
      {_, valid_feed} = Feed.new("user", "erika")
      invalid_feed = %Feed{slug: "user:", user_id: "mark", id: "user:_mark"}
      {status, error} = Feed.follow(invalid_feed, valid_feed)

      assert {:error, "DoesNotExistException"} = {status, error}
    end
  end

  test "Feed follow request with valid input returns ok" do
    use_cassette "feed_post_follow" do
      {_, source} = Feed.new("user", "eric")
      {_, target} = Feed.new("user", "jessica")
      {status, _} = Feed.follow(source, target)

      assert status == :ok
    end
  end

  test "Feed follow request to inexistent feed returns error" do
    use_cassette "feed_post_follow_inexistent" do
      {_, source} = Feed.new("alien", "eric")
      {_, target} = Feed.new("alien", "jessica")
      {status, error} = Feed.follow(source, target)

      assert status == :error
      assert error == ErrorFeedNotFound.message()
    end
  end

  test "Feed follow batch request with invalid input returns error" do
    use_cassette "feed_post_batch_follow_invalid" do
      {_, valid_feed} = Feed.new("user", "eric")
      invalid_feed = %Feed{slug: "user:", user_id: "jessica", id: "user:jessica"}
      {status, error} = Feed.follow_many([{valid_feed, invalid_feed}])

      assert status == :error
      assert error == ErrorInput.message()
    end
  end

  test "Feed follow batch request with valid input returns ok" do
    use_cassette "feed_post_batch_follow" do
      {_, source} = Feed.new("user", "eric")
      {_, target} = Feed.new("user", "deborah")
      {status, _} = Feed.follow_many([{source, target}])

      assert status == :ok
    end
  end

  test "Feed unfollow request with invalid input returns error" do
    use_cassette "feed_delete_follow_invalid" do
      {_, valid_feed} = Feed.new("user", "eric")
      invalid_feed = %Feed{slug: "user:", user_id: "jessica", id: "user:jessica"}
      {status, error} = Feed.unfollow(valid_feed, invalid_feed)

      assert status == :error
      assert error == ErrorInput.message()
    end
  end

  test "Feed unfollow request with valid input returns ok" do
    use_cassette "feed_delete_follow" do
      {_, source} = Feed.new("user", "eric")
      {_, target} = Feed.new("user", "jessica")
      {status, _} = Feed.unfollow(source, target)

      assert status == :ok
    end
  end

  test "Feed followers return a list of follow structs" do
    use_cassette "feed_get_followers" do
      {_, feed} = Feed.new("user", "jessica")
      {_, followers} = Feed.followers(feed)
      assert Enum.count(followers) == 1

      assert [%Follow{feed_id: "user:eric"} | _] = followers
    end
  end

  test "Feed followings return a list of follow structs" do
    use_cassette "feed_get_following" do
      {_, feed} = Feed.new("user", "eric")
      {_, following} = Feed.following(feed)

      assert Enum.count(following) == 0
    end
  end
end
