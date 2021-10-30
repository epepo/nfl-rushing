defmodule NFLRushing.Repo do
  use Ecto.Repo,
    otp_app: :nfl_rushing,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
