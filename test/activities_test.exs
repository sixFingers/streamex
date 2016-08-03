defmodule ActivityTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Streamex.Feed
  alias Streamex.{Config, Activity}

  doctest Streamex

  setup_all do
    Config.configure("9xup4y9pydw6", "jfw8xukqrp8axd2h5g22r67veys9qajz8aqkbsg25w3dhc6hsr737qb5wnqaywkz")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "Feed activities return a list of Activity structs" do
    use_cassette "activities_get_activities" do
      {_, feed} = new("user", "eric")
      activities = Streamex.Activities.get(feed)

      assert Enum.count(activities) == 6
      Enum.each(activities, fn(activity) ->
        assert %Activity{} = activity
      end)
    end
  end

  test "Adding an activity to feed returns a single activity struct" do
    use_cassette "activities_post_activity" do
      {_, feed} = new("user", "eric")
      activity = Streamex.Activity.new("Tony", "like", "Elixir")
      activity = Streamex.Activities.add(feed, activity)

      assert %Activity{} = activity
    end
  end

  test "Adding multiple activities to feed returns a list of activity structs" do
    use_cassette "activities_post_activities" do
      {_, feed} = new("user", "eric")
      activity_a = Streamex.Activity.new("Tony", "like", "Elixir")
      activity_b = Streamex.Activity.new("Tony", "dislike", "PHP")
      activities = Streamex.Activities.add(feed, [activity_a, activity_b])

      assert Enum.count(activities) == 2
      Enum.each(activities, fn(activity) ->
        assert %Activity{} = activity
      end)
    end
  end
end
