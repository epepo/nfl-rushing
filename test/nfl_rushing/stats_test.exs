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
  end
end
