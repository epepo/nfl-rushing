defmodule NFLRushingWeb.EntryLive.Index do
  @moduledoc """
  Displays all rushing statistics entries, allows filtering,
  ordering and exporting.
  """

  use NFLRushingWeb, :live_view

  alias NFLRushing.Stats

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(entries: Stats.list_entries())
      |> assign(player_filter: "")

    {:ok, socket}
  end

  @impl true
  def handle_event(event, unsigmned_params, socket)

  def handle_event("update_filters", %{"filters" => %{"player" => player}}, socket) do
    socket =
      socket
      |> assign(entries: Stats.list_entries(filters: %{player: player}))
      |> assign(player_filter: player)

    {:noreply, socket}
  end

  def handle_event("export", _params, socket) do
    Logger.info("Export action called")

    {:noreply, socket}
  end
end
