defmodule NFLRushing.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NFLRushing.Repo,
      NFLRushingWeb.Telemetry,
      {Phoenix.PubSub, name: NFLRushing.PubSub},
      NFLRushingWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NFLRushing.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NFLRushingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
