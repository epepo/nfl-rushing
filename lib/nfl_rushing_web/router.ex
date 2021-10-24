defmodule NFLRushingWeb.Router do
  use NFLRushingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NFLRushingWeb.LayoutView, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" => "default-src 'self'; connect-src ws: 'self'"
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NFLRushingWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: NFLRushingWeb.Telemetry
    end
  end
end
