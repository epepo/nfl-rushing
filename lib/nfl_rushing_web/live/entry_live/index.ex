defmodule NFLRushingWeb.EntryLive.Index do
  @moduledoc """
  Displays all rushing statistics entries, allows filtering,
  ordering and exporting.
  """

  use NFLRushingWeb, :live_view

  alias NFLRushing.Stats

  @columns [
    %{name: :player, text: "Player"},
    %{name: :team, text: "Team"},
    %{name: :position, text: "Pos"},
    %{name: :rushing_attempts_per_game_average, text: "Att/G"},
    %{name: :rushing_attempts, text: "Att"},
    %{name: :total_rushing_yards, text: "Yds"},
    %{name: :rushing_average_yards_per_attempt, text: "Avg"},
    %{name: :rushing_yards_per_game, text: "Yds/G"},
    %{name: :total_rushing_touchdowns, text: "TD"},
    %{name: :longest_rush, text: "Lng"},
    %{name: :rushing_first_downs, text: "1st"},
    %{name: :rushing_first_downs_percentage, text: "1st%"},
    %{name: :rushing_20_plus_yards_each, text: "20+"},
    %{name: :rushing_40_plus_yards_each, text: "40+"},
    %{name: :rushing_fumbles, text: "FUM"}
  ]

  @row_items Enum.map(@columns, & &1.name)

  @page_size 20

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Stats Entries")
      |> assign(player_filter: "")
      |> assign(order_by: {:asc, :player})
      |> assign(pagination: %{page: 0})
      |> fetch_entries()

    {:ok, socket}
  end

  @impl true
  def handle_event(event, unsigned_params, socket)

  def handle_event("update_filters", %{"filters" => %{"player" => player}}, socket) do
    socket =
      socket
      |> assign(player_filter: player)
      |> fetch_entries()

    {:noreply, socket}
  end

  def handle_event(
        "next_page",
        _unsigned_params,
        socket = %{assigns: %{pagination: pagination}}
      ) do
    socket =
      socket
      |> assign(pagination: update_in(pagination[:page], &(&1 + 1)))
      |> fetch_entries()

    {:noreply, socket}
  end

  def handle_event(
        "previous_page",
        _unsigned_params,
        socket = %{assigns: %{pagination: pagination}}
      ) do
    socket =
      socket
      |> assign(pagination: update_in(pagination[:page], &(&1 - 1)))
      |> fetch_entries()

    {:noreply, socket}
  end

  def handle_event("order_by", %{"column" => column}, socket) do
    {order, current_column} = socket.assigns.order_by

    column = String.to_existing_atom(column)

    order_by =
      if current_column == column do
        {next_order(order), column}
      else
        {:asc, column}
      end

    socket =
      socket
      |> assign(order_by: order_by)
      |> assign(current_page: 0)
      |> fetch_entries()

    {:noreply, socket}
  end

  defp next_order(:asc), do: :desc
  defp next_order(:desc), do: :asc

  defp fetch_entries(
         socket = %{
           assigns: %{
             player_filter: player_filter,
             order_by: order_by,
             pagination: pagination
           }
         }
       ) do
    page =
      Stats.fetch_entries_page(
        filters: %{player: player_filter},
        order_by: order_by,
        pagination: %{page: pagination.page, page_size: @page_size}
      )

    rows = build_table_rows(page.entries)

    socket
    |> assign(columns: @columns)
    |> assign(rows: rows)
    |> assign(
      pagination: %{
        page: page.page_number,
        total_entries: page.total_entries,
        total_pages: page.total_pages
      }
    )
  end

  defp build_table_rows(entries) do
    Enum.map(entries, fn entry ->
      longest_rush = "#{entry.longest_rush}#{if(entry.touchdown_on_longest_rush, do: "T")}"

      Enum.map(@row_items, fn
        :longest_rush -> longest_rush
        other -> Map.fetch!(entry, other)
      end)
    end)
  end

  defp sort_indicator(name, {:asc, name}), do: "▲"
  defp sort_indicator(name, {:desc, name}), do: "▼"
  defp sort_indicator(_name, _sort), do: ""

  defp export_params(player_filter, {order, field}) do
    %{"player" => player_filter, "order_by" => "#{to_string(order)}:#{field}"}
  end
end
