defmodule NFLRushingWeb.TeamLive.Index do
  use NFLRushingWeb, :live_view

  alias NFLRushing.Stats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, put_assigns(socket)}
  end

  defp put_assigns(socket) do
    socket
    |> assign(page_title: "Teams")
    |> assign(rows: Stats.fetch_teams_data())
  end
end
