defmodule NFLRushing.Exporter do
  @moduledoc """
  Utilities to export internal data to external formats.
  """

  alias NimbleCSV.RFC4180, as: CSV

  alias NFLRushing.Stats.Entry

  @definitions [
    %{field: :player, column: "Player"},
    %{field: :team, column: "Team"},
    %{field: :position, column: "Pos"},
    %{field: :rushing_attempts_per_game_average, column: "Att/G"},
    %{field: :rushing_attempts, column: "Att"},
    %{field: :total_rushing_yards, column: "Yds"},
    %{field: :rushing_average_yards_per_attempt, column: "Avg"},
    %{field: :rushing_yards_per_game, column: "Yds/G"},
    %{field: :total_rushing_touchdowns, column: "TD"},
    %{field: :longest_rush, column: "Lng"},
    %{field: :rushing_first_downs, column: "1st"},
    %{field: :rushing_first_downs_percentage, column: "1st%"},
    %{field: :rushing_20_plus_yards_each, column: "20+"},
    %{field: :rushing_40_plus_yards_each, column: "40+"},
    %{field: :rushing_fumbles, column: "FUM"}
  ]

  @columns Enum.map(@definitions, & &1.column)
  @rows Enum.map(@definitions, & &1.field)

  @doc """
  Exports a list of Entries to CSV.
  """
  @spec to_csv([Entry.t()]) :: iodata()
  def to_csv(entries) do
    row_data =
      Enum.map(entries, fn entry ->
        longest_rush = "#{entry.longest_rush}#{if(entry.touchdown_on_longest_rush, do: "T")}"

        Enum.map(@rows, fn
          :longest_rush -> longest_rush
          other -> Map.fetch!(entry, other)
        end)
      end)

    CSV.dump_to_iodata([@columns | row_data])
  end
end
