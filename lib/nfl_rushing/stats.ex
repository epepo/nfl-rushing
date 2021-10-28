defmodule NFLRushing.Stats do
  @moduledoc """
  The context for managing Rushing statistics entries.
  """

  import Ecto.Query

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @type order_by :: {:asc | :desc, atom()}
  @type filters :: %{optional(atom()) => String.t()}

  @type listing_opts :: [filters: filters(), order_by: order_by()]

  @doc """
  Returns the list of entries.

  Filters can be specified by supplying a map with Entry data to the
  `:filters` key in `opts`.
  Ordering can be specified by supplying a tuple to the `:order_by` key.

  Default filtering is none and default ordering is ascending by `:player`.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

      iex> list_entries(filters: %{player: "Joe"})
      [%Entry{player: "Joe First"}, %Entry{player: "Joe Second"}, ...]

      iex> list_entries(order_by: {:asc, :player})
      [%Entry{player: "Player A"}, %Entry{player: "Player B"}, ...]
  """
  @spec list_entries(listing_opts()) :: [Entry.t()]
  def list_entries(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    order_by = Keyword.get(opts, :order_by, {:asc, :player})

    query =
      Entry
      |> from()
      |> apply_filters(filters)
      |> apply_sorting(order_by)

    Repo.all(query)
  end

  defp apply_filters(query, filters) do
    for {key, value} <- filters, value != "", reduce: query do
      query ->
        where(
          query,
          [entry],
          ilike(field(entry, ^key), ^safe_ilike_exp(value))
        )
    end
  end

  defp safe_ilike_exp(value), do: "%#{String.replace(value, "%", "\\%")}%"

  defp apply_sorting(query, {order, name}) do
    order_by(query, [entry], [{^order, field(entry, ^name)}])
  end
end
