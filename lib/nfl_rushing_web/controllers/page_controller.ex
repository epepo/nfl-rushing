defmodule NFLRushingWeb.PageController do
  use NFLRushingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
