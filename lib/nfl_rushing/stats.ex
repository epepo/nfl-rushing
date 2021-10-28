defmodule NFLRushing.Stats do
  @moduledoc """
  The context for managing Rushing statistics entries.
  """

  import Ecto.Query

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})

    query =
      Entry
      |> from()
      |> apply_filters(filters)

    Repo.all(query)
  end

  defp apply_filters(query, filters) do
    for {key, value} <- filters, value != "", reduce: query do
      query ->
        where(
          query,
          [entry],
          ilike(field(entry, ^key), ^"%#{String.replace(value, "%", "\\%")}%")
        )
    end
  end
end
