defmodule NFLRushing.StatsTest do
  use NFLRushing.DataCase

  import NFLRushing.StatsFixtures

  alias NFLRushing.Stats

  describe "fetch_entries_page/1" do
    test "returns a page with all entries" do
      entries = for _i <- 1..3, do: entry_fixture()

      assert page = Stats.fetch_entries_page()

      assert page.total_entries == length(entries)

      for entry <- entries do
        assert entry in page.entries
      end
    end

    test "allows filtering by player name" do
      entry_fixture(player: "First Guy")
      target_entry = entry_fixture(player: "Second Dude")

      assert page = Stats.fetch_entries_page(filters: %{player: "dude"})

      assert page.total_entries == 1
      assert page.entries == [target_entry]
    end

    test "entries are ordered by player ascending by default" do
      second_entry = entry_fixture(player: "Player B")
      first_entry = entry_fixture(player: "Player A")
      last_entry = entry_fixture(player: "Player C")

      assert Stats.fetch_entries_page().entries == [
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

      assert Stats.fetch_entries_page(opts).entries == [
               first_entry,
               second_entry,
               last_entry
             ]
    end

    test "allows specifying page size" do
      for _i <- 1..10, do: entry_fixture()

      assert page = Stats.fetch_entries_page(pagination: %{page_size: 5})

      assert page.page_number == 1
      assert page.page_size == 5
      assert page.total_pages == 2

      assert length(page.entries) == 5
    end

    test "allows specifying which page to fetch" do
      for _i <- 1..10, do: entry_fixture()

      assert page = Stats.fetch_entries_page(pagination: %{page: 2, page_size: 5})

      assert page.page_number == 2
      assert page.page_size == 5
      assert page.total_pages == 2

      assert length(page.entries) == 5
    end
  end

  describe "list_entries/1" do
    test "returns all entries" do
      entries = for _i <- 1..3, do: entry_fixture()

      assert result = Stats.list_entries()

      for entry <- entries do
        assert entry in result
      end
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
