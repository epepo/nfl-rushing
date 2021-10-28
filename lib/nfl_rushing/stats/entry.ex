defmodule NFLRushing.Stats.Entry do
  @moduledoc """
  An Entry with rushing statistics for a given player.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

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
    |> cast(attrs, fields())
    |> validate_required(fields())
  end

  defp fields, do: __schema__(:fields) -- [:id, :inserted_at, :updated_at]
end
