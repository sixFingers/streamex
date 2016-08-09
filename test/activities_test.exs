defmodule ActivityTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Streamex.Feed
  alias Streamex.{Config, Feed, Activity, Activities, ErrorNotFound, ErrorInput}

  doctest Streamex

  setup_all do
    Config.configure()
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed activities returns a list of %Activity{}" do
    use_cassette "activities_get_activities" do
      {_, feed} = new("user", "eric")
      {__, activities} = Streamex.Activities.get(feed)

      assert Enum.count(activities) == 2
      assert [%Activity{} | _] = activities
    end
  end

  test "Invalid feed activities returns ErrorNotFound" do
    use_cassette "activities_get_activities_invalid_feed" do
      feed = %Feed{slug: "user:", user_id: "jessica", id: "user:jessica"}
      {status, error} = Streamex.Activities.get(feed)

      assert status == :error
      assert error == ErrorNotFound.message
    end
  end

  test "Adding an activity without custom fields to feed returns an %Activity{}" do
    use_cassette "activities_post_activity" do
      {_, feed} = new("user", "eric")
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:elixir"}
      {_, activity} = Streamex.Activities.add(feed, activity)

      assert %Activity{} = activity
    end
  end

  test "Adding an activity custom fields to feed returns a single activity struct with custom fields" do
    use_cassette "activities_post_activity_with_custom_fields" do
      {_, feed} = new("user", "eric")
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:elixir", "custom_field" => "custom_value"}
      {_, activity} = Streamex.Activities.add(feed, activity)

      assert %Activity{custom_fields: %{"custom_field" => "custom_value"}} = activity
    end
  end

  test "Adding an activity to invalid feed returns ErrorNotFound" do
    use_cassette "activities_post_activity_invalid_feed" do
      feed = %Feed{slug: "user:", user_id: "jessica", id: "user:jessica"}
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:elixir"}
      {status, error} = Streamex.Activities.add(feed, activity)

      assert status == :error
      assert error == ErrorNotFound.message
    end
  end

  test "Adding multiple activities to feed returns a list of activity structs" do
    use_cassette "activities_post_activities" do
      {_, feed} = new("user", "eric")
      activity_a = %{"actor" => "Tony", "verb" => "like", "object" => "Ruby"}
      activity_b = %{"actor" => "Tony", "verb" => "dislike", "object" => "PHP"}
      {__, activities} = Streamex.Activities.add(feed, [activity_a, activity_b])

      assert Enum.count(activities) == 2
      assert [%Activity{} | _] = activities
    end
  end

  test "Adding an activity to multiple feeds returns ok" do
    use_cassette "activities_post_batch_activities" do
      {_, feed} = Feed.new("user", "erika")
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:elixir"}
      {status, _} = Activities.add_to_many(activity, [feed])

      assert status == :ok
    end
  end

  test "Adding an activity to multiple invalid feeds returns ErrorInput" do
    use_cassette "activities_post_batch_activities_invalid_feed" do
      feed = %Feed{slug: "user:", user_id: "jessica", id: "user:jessica"}
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir", "foreign_id" => "tony:elixir"}
      {status, error} = Activities.add_to_many(activity, [feed])

      assert status == :error
      assert error == ErrorInput.message
    end
  end

  test "Updating an activity without required fields returns ErrorInput" do
    use_cassette "activities_update_activity_missing_field" do
      {_, feed} = new("user", "eric")
      activity = %{"actor" => "Tony", "verb" => "love", "object" => "Elixir", "foreign_id" => "tony:elixir"}
      {status, error} = Activities.update(feed, activity)

      assert status == :error
      assert error == ErrorInput.message
    end
  end

  test "Removing an activity by activity_id returns ok" do
    use_cassette "activities_delete_activity_by_activity_id" do
      {_, feed} = new("user", "eric")
      {status, id} = Activities.remove(feed, "d2d6fc2c-5e5a-11e6-8080-80017383369d")

      assert {:ok, "d2d6fc2c-5e5a-11e6-8080-80017383369d"} == {status, id}
    end
  end

  test "Removing an activity by foreign_id returns ok" do
    use_cassette "activities_delete_activity_by_foreign_id" do
      {_, feed} = new("user", "eric")
      {status, id} = Activities.remove(feed, "tony:elixir", foreign_id: true)

      assert {:ok, "tony:elixir"} == {status, id}
    end
  end
end
