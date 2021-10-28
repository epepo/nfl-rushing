defmodule NFLRushing.StatsTest do
  use NFLRushing.DataCase

  import NFLRushing.StatsFixtures

  alias NFLRushing.Stats

  describe "list_entries/0" do
    test "returns all entries" do
      entry = entry_fixture()

      assert Stats.list_entries() == [entry]
    end

    test "allows filtering by player name" do
      entry_fixture(player: "First Guy")
      target_entry = entry_fixture(player: "Second Dude")

      assert Stats.list_entries(filters: %{player: "dude"}) == [target_entry]
    end

    test "entries are ordered by player ascending by default" do
      second_entry = entry_fixture(player: "Player B")
      first_entry = entry_fixture(player: "Player A")
      last_entry = entry_fixture(player: "Player C")

      assert Stats.list_entries() == [
               first_entry,
               second_entry,
               last_entry
             ]
    end

    test "allows ordering by a specific field" do
      second_entry = entry_fixture(rushing_attempts: 10)
      first_entry = entry_fixture(rushing_attempts: 5)
      last_entry = entry_fixture(rushing_attempts: 12)

      opts = [order_by: {:asc, :rushing_attempts}]

      assert Stats.list_entries(opts) == [
               first_entry,
               second_entry,
               last_entry
             ]
    end
  end
end
