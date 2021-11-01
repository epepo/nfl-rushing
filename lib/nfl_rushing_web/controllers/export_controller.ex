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
          |> Exporter.to_csv_stream()

        conn
        |> put_resp_header("content-disposition", "attachment; filename=\"#{@filename}\"")
        |> put_resp_header("content-type", "text/csv")
        |> send_chunked(200)
        |> stream_data(data)

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

  defp stream_data(conn, data) do
    Enum.reduce_while(data, conn, fn part, conn ->
      case chunk(conn, part) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end
end
