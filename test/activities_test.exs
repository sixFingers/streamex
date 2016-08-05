defmodule ActivityTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Streamex.Feed
  alias Streamex.{Config, Activity, Activities}

  doctest Streamex

  setup_all do
    Config.configure("q8v3a7aurm9s", "ve5h9s5y9yshmrkfsu2zsnm7xs83xmznvuwhy5zdyz82dmczufczmqekbfre4qsh")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed activities return a list of Activity structs" do
    use_cassette "activities_get_activities" do
      {_, feed} = new("user", "eric")
      {__, activities} = Streamex.Activities.get(feed)

      assert Enum.count(activities) == 2
      Enum.each(activities, fn(activity) ->
        assert %Activity{} = activity
      end)
    end
  end

  test "Adding an activity without custom fields to feed returns a single activity struct" do
    use_cassette "activities_post_activity" do
      {_, feed} = new("user", "eric")
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir"}
      activity = Streamex.Activities.add(feed, activity)

      assert %Activity{} = activity
    end
  end

  test "Adding multiple activities to feed returns a list of activity structs" do
    use_cassette "activities_post_activities" do
      {_, feed} = new("user", "eric")
      activity_a = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir"}
      activity_b = %{"actor" => "Tony", "verb" => "dislike", "object" => "PHP"}
      {__, activities} = Streamex.Activities.add(feed, [activity_a, activity_b])

      assert Enum.count(activities) == 2
      Enum.each(activities, fn(activity) ->
        assert %Activity{} = activity
      end)
    end
  end

  test "Adding an activity to multiple feeds returns ok" do
    use_cassette "activities_post_batch_activities" do
      activity = %{"actor" => "Tony", "verb" => "like", "object" => "Elixir"}
      {status, _} = Activities.add_to_many(activity, [{"user", "jessica"}, {"user", "deborah"}])

      assert status == :ok
    end
  end

  test "Updating an activity returns ok" do
    use_cassette "activities_update_activity" do
      {_, feed} = new("user", "eric")
      activity = %{"actor" => "Eric", "verb" => "like", "object" => "Elixir", "foreign_id" => "eric:elixir", "time" => "2016-08-03T14:48:14.891095"}
      {status, _} = Activities.update(feed, activity)

      assert status == :ok
    end
  end

  test "Removing an activity by activity_id returns ok" do
    use_cassette "activities_delete_activity_by_activity_id" do
      {_, feed} = new("user", "eric")
      {status, _} = Activities.remove(feed, "4ece4366-5989-11e6-8080-800100a161a4")

      assert status == :ok
    end
  end
end
