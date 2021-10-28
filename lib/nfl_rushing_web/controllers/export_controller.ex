defmodule NFLRushingWeb.ExportController do
  use NFLRushingWeb, :controller

  alias NFLRushing.Exporter
  alias NFLRushing.Stats

  @filename "export.csv"

  def show(conn, params) do
    player = Map.get(params, "player")
    order_by = Map.get(params, "order_by")

    case parse_order_by(order_by) do
      {:ok, order_by} ->
        data =
          player
          |> build_opts(order_by)
          |> Stats.list_entries()
          |> Exporter.to_csv()

        send_download(conn, {:binary, data}, filename: @filename)

      {:error, reason} ->
        send_resp(conn, reason, "")
    end
  end

  defp parse_order_by(nil), do: {:ok, nil}
  defp parse_order_by("asc:" <> field), do: {:ok, {:asc, String.to_existing_atom(field)}}
  defp parse_order_by("desc:" <> field), do: {:ok, {:desc, String.to_existing_atom(field)}}
  defp parse_order_by(_other), do: {:error, :bad_request}

  defp build_opts(player, order_by) do
    opts = []

    opts =
      if player do
        [filters: %{player: player}] ++ opts
      else
        opts
      end

    if order_by do
      [order_by: order_by] ++ opts
    else
      opts
    end
  end
end
