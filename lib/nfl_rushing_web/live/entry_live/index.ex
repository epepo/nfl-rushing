defmodule NFLRushingWeb.EntryLive.Index do
  @moduledoc """
  Displays all rushing statistics entries, allows filtering,
  ordering and exporting.
  """

  use NFLRushingWeb, :live_view

  alias NFLRushing.Stats

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, entries: Stats.list_entries())

    {:ok, socket}
  end
end
