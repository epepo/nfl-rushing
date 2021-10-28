defmodule NFLRushing.ExporterTest do
  use NFLRushing.DataCase

  import NFLRushing.StatsFixtures

  alias NFLRushing.Exporter

  describe "to_csv/1" do
    test "renders entries as expected" do
      entries = for _i <- 1..3, do: entry_fixture()

      csv =
        entries
        |> Exporter.to_csv()
        |> IO.iodata_to_binary()

      for entry <- entries do
        assert csv =~ entry.player
      end
    end

    test "renders only columns if no entries are provided" do
      assert []
             |> Exporter.to_csv()
             |> IO.iodata_to_binary()
             |> String.split()
             |> Enum.count() == 1
    end
  end
end
