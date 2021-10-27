defmodule NFLRushingWeb.EntryLiveTest do
  use NFLRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  import NFLRushing.StatsFixtures

  defp create_entry(_context) do
    entry = entry_fixture()

    %{entry: entry}
  end

  describe "index" do
    setup [:create_entry]

    test "lists all entries", %{conn: conn, entry: entry} do
      {:ok, _index_live, html} = live(conn, Routes.entry_index_path(conn, :index))

      assert html =~ "Player"
      assert html =~ entry.player
    end
  end
end
