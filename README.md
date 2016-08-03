# Streamex [![Build Status](https://travis-ci.org/sixFingers/streamex.svg?branch=master)](https://travis-ci.org/sixFingers/streamex) [![Coverage Status](https://coveralls.io/repos/github/sixFingers/streamex/badge.svg?branch=master)](https://coveralls.io/github/sixFingers/streamex?branch=master)

Streamex is a [GetStream](https://getstream.io) client library for the Elixir language.

# Usage

  ```elixir
  # Configure the client
  Streamex.Config.configure("key", "secret", "region")

  # Create a new feed
  {status, feed} = Streamex.Feed.new("user", "eric")

  # Get activities
  activities = Streamex.Activities.get(feed)
  activities = Streamex.Activities.get(feed, limit: 5, offset: 5)

  # Create activity
  basic = Streamex.Activity.new("Tony", "like", "Elixir")
  optional = Streamex.Activity.new("Linda", "like", "Ruby", [foreign_id: "like:1"])
  custom = Streamex.Activity.new("Jack", "like", "AfterEffects", [foreign_id: "like:1"], %{"age" => 23})

  # Add activity to stream
  activity = Streamex.Activities.add(feed, basic)
  activities = Streamex.Activities.add(feed, [basic, optional, custom])

  # Update activity
  optional = %{optional | verb: "dislikes"}
  Streamex.Activities.update(feed, optional)

  # Remove activity by id
  Streamex.Activities.remove(feed, id)
  # Remove activity by foreign_id
  Streamex.Activities.remove(feed, foreign_id, true)

  # Get followers
  Streamex.Feed.followers(feed)
  # Get following
  Streamex.Feed.following(feed)

  # Start following another feed
  Streamex.Feed.follow(feed, "user", "jessica")
  # Stop following another feed
  Streamex.Feed.unfollow(feed, "user", "jessica")

  # Batch add an activity to many feeds
  Streamex.Activities.add_to_many(basic, [{"user", "jessica"}, {"user", "deborah"}])

  # Batch follow
  followings = [{
    #source
    {"user:", "eric"},
    #target
    {"user", "jessica"}
  }, {
    {"user", "eric"},
    {"user", "deborah"}
  }]
  Streamex.Feed.follow_many(followings)
  ```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `streamex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:streamex, "~> 0.3.0"}]
    end
    ```

  2. Ensure `streamex` is started before your application:

    ```elixir
    def application do
      [applications: [:streamex]]
    end
    ```

