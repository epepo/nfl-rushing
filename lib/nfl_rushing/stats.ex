defmodule NFLRushing.Stats do
  @moduledoc """
  The context for managing Rushing statistics entries.
  """

  import Ecto.Query

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @default_filters %{}
  @default_order_by {:asc, :player}
  @default_pagination %{page: 1, page_size: 20}

  @type order_by :: {:asc | :desc, field :: atom()}
  @type filters :: %{optional(atom()) => String.t()}
  @type pagination_opts :: %{page: non_neg_integer(), page_size: non_neg_integer()}

  @type page(item) :: %Scrivener.Page{
          entries: [item],
          page_number: pos_integer(),
          page_size: non_neg_integer(),
          total_entries: non_neg_integer(),
          total_pages: non_neg_integer()
        }

  @typedoc """
  Options for operations that list Entries.

  Default values:

  `:filters` is `#{inspect(@default_filters)}`;
  `:order_by` is `#{inspect(@default_order_by)}`;
  `:pagination` is `#{inspect(@default_pagination)}`.

  Note: `:pagination`'s page is one-based.
  """
  @type listing_opts :: [
          filters: filters(),
          order_by: order_by(),
          pagination: pagination_opts()
        ]

  def fetch_teams_data do
    Repo.all(teams_query())
  end

  defp teams_query do
    Entry
    |> from()
    |> group_by([entry], entry.team)
    |> select([entry], %{
      team: entry.team,
      sum_of_total_rushing_yards: sum(entry.total_rushing_yards),
      average_longest_rush: avg(entry.longest_rush)
    })
    |> order_by([entry], entry.team)
  end

  @doc """
  Fetches a page of Entries.
  """
  @spec fetch_entries_page(listing_opts()) :: page(Entry.t())
  def fetch_entries_page(opts \\ []) do
    parsed_opts = get_options(opts)

    parsed_opts
    |> entries_query()
    |> Repo.paginate(parsed_opts.pagination)
  end

  @doc """
  Fetches a list of Entries.

  This function respects `opts` except for the `:pagination` option.
  """
  @spec list_entries(listing_opts()) :: [Entry.t()]
  def list_entries(opts \\ []) do
    parsed_opts = get_options(opts)

    parsed_opts
    |> entries_query()
    |> Repo.all()
  end

  defp get_options(opts) do
    filters = Keyword.get(opts, :filters, @default_filters)
    order_by = Keyword.get(opts, :order_by, @default_order_by)

    pagination = Keyword.get(opts, :pagination, %{})

    %{
      filters: filters,
      order_by: order_by,
      pagination: Map.merge(@default_pagination, pagination)
    }
  end

  defp entries_query(%{filters: filters, order_by: order_by}) do
    Entry
    |> from()
    |> apply_filters(filters)
    |> apply_sorting(order_by)
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

  defp safe_ilike_exp(value) do
    value =
      value
      |> String.replace("%", "\\%")
      |> String.replace("_", "\\_")

    "%#{value}%"
  end

  defp apply_sorting(query, {order, name}) do
    order_by(query, [entry], [{^order, field(entry, ^name)}])
  end
end
