defmodule NFLRushing.Importer do
  @moduledoc """
  Parses supported JSON data into Stats Entries.
  """

  alias Ecto.Changeset

  alias NFLRushing.Stats.Entry

  @numeric_fields_mapping %{
    rushing_attempts_per_game_average: "Att/G",
    total_rushing_yards: "Yds",
    rushing_average_yards_per_attempt: "Avg",
    rushing_yards_per_game: "Yds/G",
    rushing_first_downs_percentage: "1st%",
    rushing_attempts: "Att",
    total_rushing_touchdowns: "TD",
    rushing_first_downs: "1st",
    rushing_20_plus_yards_each: "20+",
    rushing_40_plus_yards_each: "40+",
    rushing_fumbles: "FUM"
  }

  @string_fields_mapping %{
    player: "Player",
    position: "Pos",
    team: "Team"
  }

  @longest_rush_external_field "Lng"
  @longest_rush_internal_field :longest_rush
  @longest_rush_touchdown_field :touchdown_on_longest_rush
  @touchdown_marker "T"

  @doc """
  Parses a map that contains data for an Entry.
  """
  @spec parse_entry!(map()) :: Entry.t() | no_return()
  def parse_entry!(data) do
    {longest_rush, touchdown?} = parse_longest_rush(data)

    attrs =
      %{
        @longest_rush_internal_field => longest_rush,
        @longest_rush_touchdown_field => touchdown?
      }
      |> put_numeric_fields(data)
      |> put_string_fields(data)

    %Entry{}
    |> Entry.changeset(attrs)
    |> Changeset.apply_action!(:insert)
  end

  defp parse_longest_rush(data) do
    data
    |> Map.fetch!(@longest_rush_external_field)
    |> case do
      value when is_binary(value) ->
        value
        |> maybe_remove_comma()
        |> Float.parse()

      value ->
        {value, ""}
    end
    |> parse_touchdown_marker()
  end

  defp parse_touchdown_marker({longest_rush, @touchdown_marker}) do
    {longest_rush, true}
  end

  defp parse_touchdown_marker({longest_rush, ""}) do
    {longest_rush, false}
  end

  defp parse_touchdown_marker({_longest_rush, other}) do
    raise ArgumentError, ~s|Expected "T" or "" as Lng's touchdown marker, got "#{other}"|
  end

  defp put_numeric_fields(attrs, data) do
    Enum.reduce(@numeric_fields_mapping, attrs, &fetch_numeric_field(data, &1, &2))
  end

  defp put_string_fields(attrs, data) do
    Enum.reduce(@string_fields_mapping, attrs, &fetch_string_field(data, &1, &2))
  end

  defp fetch_numeric_field(data, {destination, source}, acc) do
    value =
      data
      |> Map.fetch!(source)
      |> maybe_remove_comma()

    Map.put(acc, destination, value)
  end

  defp fetch_string_field(data, {destination, source}, acc) do
    Map.put(acc, destination, Map.fetch!(data, source))
  end

  defp maybe_remove_comma(data) when is_binary(data) do
    String.replace(data, ",", "")
  end

  defp maybe_remove_comma(data), do: data
end
