defmodule NFLRushingWeb.Router do
  use NFLRushingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :put_root_layout, {NFLRushingWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NFLRushingWeb do
    pipe_through :browser

    live "/", EntryLive.Index, :index
    get "/export", ExportController, :show
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: NFLRushingWeb.Telemetry,
        ecto_repos: [NFLRushing.Repo]
    end
  end
end
