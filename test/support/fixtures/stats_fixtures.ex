defmodule NFLRushing.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities for the `NFLRushing.Stats` context.
  """

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @positions [
    "RB",
    "QB",
    "SS",
    "K",
    "NT",
    "FB",
    "P",
    "WR",
    "DB",
    "TE"
  ]

  @teams [
    "DEN",
    "CHI",
    "HOU",
    "NYJ",
    "IND",
    "ATL",
    "PIT",
    "CLE",
    "BAL",
    "KC",
    "DAL",
    "TEN",
    "BUF",
    "WAS",
    "ARI",
    "NE",
    "OAK",
    "TB",
    "SD",
    "NYG",
    "LA",
    "SF",
    "NO",
    "GB",
    "CIN",
    "MIN",
    "JAX",
    "CAR",
    "SEA",
    "PHI",
    "MIA",
    "DET"
  ]

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    data =
      Enum.into(
        attrs,
        %{
          player: Faker.Person.name(),
          position: Enum.random(@positions),
          team: Enum.random(@teams),
          rushing_attempts_per_game_average: random_float(),
          rushing_attempts: random_int(),
          total_rushing_yards: random_float(),
          rushing_average_yards_per_attempt: random_float(),
          rushing_yards_per_game: random_float(),
          total_rushing_touchdowns: random_int(),
          longest_rush: random_float(),
          touchdown_on_longest_rush: Enum.random([true, false]),
          rushing_first_downs: random_int(),
          rushing_first_downs_percentage: random_float(),
          rushing_20_plus_yards_each: random_int(),
          rushing_40_plus_yards_each: random_int(),
          rushing_fumbles: random_int()
        }
      )

    %Entry{}
    |> Entry.changeset(data)
    |> Repo.insert!()
  end

  defp random_float do
    random_int() + Enum.random(0..9) / 10
  end

  defp random_int do
    Enum.random(1..200)
  end
end
