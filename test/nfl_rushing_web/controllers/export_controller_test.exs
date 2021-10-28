defmodule NFLRushingWeb.ExportControllerTest do
  use NFLRushingWeb.ConnCase

  import NFLRushing.StatsFixtures

  describe "GET /" do
    test "includes all entries by default", %{conn: conn} do
      entries = for _i <- 1..3, do: entry_fixture()

      path = Routes.export_path(conn, :show)

      assert result =
               conn
               |> get(path)
               |> response(200)

      for entry <- entries do
        assert result =~ entry.player
      end
    end

    test "works with no data", %{conn: conn} do
      path = Routes.export_path(conn, :show)

      assert result =
               conn
               |> get(path)
               |> response(200)

      assert result
    end

    test "allows filtering by players", %{conn: conn} do
      target_player = entry_fixture(player: "Target")
      other_player = entry_fixture()

      path = Routes.export_path(conn, :show)

      assert result =
               conn
               |> get(path, %{"player" => "tar"})
               |> response(200)

      assert result =~ target_player.player
      refute result =~ other_player.player
    end

    test "allows sorting", %{conn: conn} do
      %{player: second_player} = entry_fixture(rushing_attempts: 10)
      %{player: third_player} = entry_fixture(rushing_attempts: 5)
      %{player: first_player} = entry_fixture(rushing_attempts: 12)

      path = Routes.export_path(conn, :show)

      assert [_columns, first_result, second_result, third_result] =
               conn
               |> get(path, %{"order_by" => "desc:rushing_attempts"})
               |> response(200)
               |> String.trim()
               |> String.split("\r\n")

      assert first_result =~ first_player
      assert second_result =~ second_player
      assert third_result =~ third_player
    end
  end
end
