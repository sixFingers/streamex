# Streamex

Streamex is a [GetStream](https://getstream.io) client library for the Elixir language.

**Pre-pre-pre-alpha status: don't use this. Yet.**

# Usage

  ```elixir
  # Create a new feed
  f = Streamex.Feed.new("user", "eric")

  # Get activities
  Streamex.Activities.get(f)
  Streamex.Activities.get(f, limit: 5, offset: 5)

  # Create activity
  basic = Streamex.Activity.new("Tony", "like", "Elixir")
  optional = Streamex.Activity.new("Linda", "like", "Ruby", [foreign_id: "like:1"])
  custom = Streamex.Activity.new("Jack", "like", "AfterEffects", [foreign_id: "like:1"], %{"age" => 23})

  # Add activity to stream
  Streamex.Activities.add(f, basic)
  Streamex.Activities.add(f, [basic, optional, custom])

  # Update activity
  optional = %{optional | verb: "dislikes"}
  Streamex.Activities.update(f, optional)

  # Remove activity by id
  Streamex.Activities.remove(f, [id returned from api])
  # Remove activity by foreign_id
  Streamex.Activities.remove(f, "like:1", true)

  # Get followers
  Streamex.Feed.followers(f)
  # Get following
  Streamex.Feed.following(f)

  # Start following another feed
  Streamex.Feed.follow(f, "user", "jessica")
  # Stop following another feed
  Streamex.Feed.unfollow(f, "user", "jessica")

  # Batch add an activity to many feeds
  Streamex.Activities.add_to_many(basic, ["user:jessica"])

  ```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `streamex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:streamex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `streamex` is started before your application:

    ```elixir
    def application do
      [applications: [:streamex]]
    end
    ```

