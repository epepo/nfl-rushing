defmodule NFLRushing.ImporterTest do
  use NFLRushing.DataCase

  alias NFLRushing.Importer
  alias NFLRushing.Stats.Entry

  @valid_attrs %{
    "Player" => "Joe Banyard",
    "Team" => "JAX",
    "Pos" => "RB",
    "Att" => 2,
    "Att/G" => 2,
    "Yds" => 7,
    "Avg" => 3.5,
    "Yds/G" => 7,
    "TD" => 0,
    "Lng" => "7",
    "1st" => 0,
    "1st%" => 0,
    "20+" => 0,
    "40+" => 0,
    "FUM" => 0
  }

  describe "parse_entry!/1" do
    test "parses a well formatted entry" do
      assert %Entry{} = Importer.parse_entry!(@valid_attrs)
    end

    test "parses an entry where the longest rush had a touchdown" do
      attrs = Map.put(@valid_attrs, "Lng", "8T")

      assert entry = Importer.parse_entry!(attrs)

      assert entry.longest_rush == 8.0
      assert entry.touchdown_on_longest_rush
    end

    test "parses entries that have commas on numbers" do
      attrs = Map.put(@valid_attrs, "Yds", "1,043")

      assert entry = Importer.parse_entry!(attrs)

      assert entry.total_rushing_yards == 1043.0
    end

    test "raises if fields are missing" do
      attrs = Map.delete(@valid_attrs, "TD")

      assert_raise KeyError, fn ->
        Importer.parse_entry!(attrs)
      end
    end

    test "raises if longest rush has an invalid marker" do
      attrs = Map.put(@valid_attrs, "Lng", "7Y")

      assert_raise ArgumentError, fn ->
        Importer.parse_entry!(attrs)
      end
    end
  end
end
