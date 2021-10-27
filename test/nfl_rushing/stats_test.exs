defmodule NFLRushing.StatsTest do
  use NFLRushing.DataCase

  import NFLRushing.StatsFixtures

  alias NFLRushing.Stats

  describe "list_entries/0" do
    test "returns all entries" do
      entry = entry_fixture()

      assert Stats.list_entries() == [entry]
    end
  end
end
