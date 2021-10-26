defmodule NFLRushing.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :player, :string, null: false
      add :position, :string, null: false
      add :team, :string, null: false

      add :rushing_attempts_per_game_average, :float, null: false
      add :rushing_attempts, :integer, null: false
      add :total_rushing_yards, :float, null: false
      add :rushing_average_yards_per_attempt, :float, null: false
      add :rushing_yards_per_game, :float, null: false
      add :total_rushing_touchdowns, :integer, null: false
      add :longest_rush, :float, null: false
      add :touchdown_on_longest_rush, :boolean, null: false
      add :rushing_first_downs, :integer, null: false
      add :rushing_first_downs_percentage, :float, null: false
      add :rushing_20_plus_yards_each, :integer, null: false
      add :rushing_40_plus_yards_each, :integer, null: false
      add :rushing_fumbles, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
