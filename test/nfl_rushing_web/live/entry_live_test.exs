defmodule NFLRushingWeb.EntryLiveTest do
  use NFLRushingWeb.ConnCase

  import Phoenix.LiveViewTest
  import NFLRushing.StatsFixtures

  describe "index" do
    test "lists all entries", %{conn: conn} do
      entry = entry_fixture()

      {:ok, _index_live, html} = live(conn, Routes.entry_index_path(conn, :index))

      assert html =~ "Player"
      assert html =~ entry.player
    end

    test "allows filtering by player name", %{conn: conn} do
      target_entry = entry_fixture(player: "Target Player")
      other_entry = entry_fixture(player: "Some Other Player")

      {:ok, live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      html =
        live
        |> form("#filters", filters: %{player: target_entry.player})
        |> render_change()

      assert html =~ target_entry.player
      refute html =~ other_entry.player
    end

    test "allows sorting by some column", %{conn: conn} do
      second_entry = entry_fixture(rushing_attempts: 10)
      first_entry = entry_fixture(rushing_attempts: 5)
      last_entry = entry_fixture(rushing_attempts: 12)

      {:ok, live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      live
      |> element(~s|*[phx-value-column="rushing_attempts"]|)
      |> render_click()

      assert has_element?(live, "tbody > tr:nth-child(1) > td:first-child()", first_entry.player)
      assert has_element?(live, "tbody > tr:nth-child(2) > td:first-child()", second_entry.player)
      assert has_element?(live, "tbody > tr:nth-child(3) > td:first-child()", last_entry.player)
    end

    test "allows exporting data respecting filtering and ordering", %{conn: conn} do
      {:ok, live, _html} = live(conn, Routes.entry_index_path(conn, :index))

      live
      |> element(~s|*[phx-value-column="rushing_attempts"]|)
      |> render_click()

      live
      |> form("#filters", filters: %{player: "target"})
      |> render_change()

      live
      |> element("a", "Export")
      |> render_click()

      assert_redirect(
        live,
        Routes.export_path(conn, :show, %{
          "order_by" => "asc:rushing_attempts",
          "player" => "target"
        })
      )
    end
  end
end
