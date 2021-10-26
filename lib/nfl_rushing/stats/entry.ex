defmodule NFLRushing.Stats.Entry do
  @moduledoc """
  An Entry with rushing statistics for a given player.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          player: String.t(),
          position: String.t(),
          team: String.t(),
          rushing_attempts_per_game_average: number(),
          rushing_attempts: integer(),
          total_rushing_yards: number(),
          rushing_average_yards_per_attempt: number(),
          rushing_yards_per_game: number(),
          total_rushing_touchdowns: integer(),
          longest_rush: number(),
          touchdown_on_longest_rush: boolean(),
          rushing_first_downs: integer(),
          rushing_first_downs_percentage: number(),
          rushing_20_plus_yards_each: integer(),
          rushing_40_plus_yards_each: integer(),
          rushing_fumbles: integer(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @fields [
    :player,
    :position,
    :team,
    :rushing_attempts_per_game_average,
    :rushing_attempts,
    :total_rushing_yards,
    :rushing_average_yards_per_attempt,
    :rushing_yards_per_game,
    :total_rushing_touchdowns,
    :longest_rush,
    :touchdown_on_longest_rush,
    :rushing_first_downs,
    :rushing_first_downs_percentage,
    :rushing_20_plus_yards_each,
    :rushing_40_plus_yards_each,
    :rushing_fumbles
  ]
  @required_fields @fields

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "entries" do
    field :player, :string
    field :position, :string
    field :team, :string

    field :rushing_attempts_per_game_average, :float
    field :rushing_attempts, :integer
    field :total_rushing_yards, :float
    field :rushing_average_yards_per_attempt, :float
    field :rushing_yards_per_game, :float
    field :total_rushing_touchdowns, :integer
    field :longest_rush, :float
    field :touchdown_on_longest_rush, :boolean
    field :rushing_first_downs, :integer
    field :rushing_first_downs_percentage, :float
    field :rushing_20_plus_yards_each, :integer
    field :rushing_40_plus_yards_each, :integer
    field :rushing_fumbles, :integer

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
