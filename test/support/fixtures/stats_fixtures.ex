defmodule NFLRushing.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities for the `NFLRushing.Stats` context.
  """

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    data =
      Enum.into(
        attrs,
        %{
          player: "Some Player",
          position: "POS",
          team: "TEAM",
          rushing_attempts_per_game_average: 1.1,
          rushing_attempts: 2,
          total_rushing_yards: 3.3,
          rushing_average_yards_per_attempt: 4.4,
          rushing_yards_per_game: 5.5,
          total_rushing_touchdowns: 6,
          longest_rush: 7.7,
          touchdown_on_longest_rush: true,
          rushing_first_downs: 9,
          rushing_first_downs_percentage: 10.10,
          rushing_20_plus_yards_each: 11,
          rushing_40_plus_yards_each: 12,
          rushing_fumbles: 13
        }
      )

    %Entry{}
    |> Entry.changeset(data)
    |> Repo.insert!()
  end
end
