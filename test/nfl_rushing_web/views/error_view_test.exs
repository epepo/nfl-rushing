defmodule NFLRushingWeb.ErrorViewTest do
  use NFLRushingWeb.ConnCase, async: true

  import Phoenix.View, only: [render_to_string: 3]

  test "renders 404.html" do
    assert render_to_string(NFLRushingWeb.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(NFLRushingWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
