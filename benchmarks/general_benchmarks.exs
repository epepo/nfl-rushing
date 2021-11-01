defmodule NFLRushing.GeneralBenchmarks do
  @moduledoc """
  The benchmarks here are intended to give an overview of
  the relative performance of the main operations an user
  might end up running.
  """

  import NFLRushing.StatsFixtures

  alias Ecto.Adapters.SQL.Sandbox

  alias NFLRushing.Exporter
  alias NFLRushing.Repo
  alias NFLRushing.Stats

  require Logger

  @entries_count 200_000

  def run do
    Logger.configure(level: :info)

    Sandbox.mode(Repo, :manual)

    pid = Sandbox.start_owner!(Repo, shared: false)

    for _i <- 1..@entries_count, do: entry_fixture()

    Benchee.run(
      %{
        "list_entries/1 with no params" => &list_entries_no_params/0,
        "list_entries/1 with csv export" => &list_entries_with_csv_export/0,
        "list_entries/1 with player filter" => &list_entries_with_player_filter/0,
        "list_entries/1 ordered by total rushing yards" => &list_entries_ordered_by_total_rushing_yards/0,
        "list_entries/1 ordered by longest rush" => &list_entries_ordered_by_longest_rush/0,
        "list_entries/1 ordered by total rushing touchdowns" => &list_entries_ordered_by_total_rushing_touchdowns/0,
        "fetch_entries_page/1 with no params" => &fetch_entries_page_no_params/0,
        "fetch_entries_page/1 with csv export" => &fetch_entries_page_with_csv_export/0,
        "fetch_entries_page/1 with player filter" => &fetch_entries_page_with_player_filter/0,
        "fetch_entries_page/1 ordered by total rushing yards" => &fetch_entries_page_ordered_by_total_rushing_yards/0,
        "fetch_entries_page/1 ordered by longest rush" => &fetch_entries_page_ordered_by_longest_rush/0,
        "fetch_entries_page/1 ordered by total rushing touchdowns" => &fetch_entries_page_ordered_by_total_rushing_touchdowns/0,
      }
    )

    Sandbox.stop_owner(pid)
  end

  defp list_entries_no_params, do: Stats.list_entries()
  defp list_entries_with_csv_export, do: Stats.list_entries() |> Exporter.to_csv_stream() |> Enum.to_list()
  defp list_entries_with_player_filter, do: Stats.list_entries(filters: %{player: " IV"})
  defp list_entries_ordered_by_total_rushing_yards, do: Stats.list_entries(order_by: {:asc, :total_rushing_yards})
  defp list_entries_ordered_by_longest_rush, do: Stats.list_entries(order_by: {:asc, :longest_rush})
  defp list_entries_ordered_by_total_rushing_touchdowns, do: Stats.list_entries(order_by: {:asc, :total_rushing_touchdowns})

  defp fetch_entries_page_no_params, do: Stats.fetch_entries_page()
  defp fetch_entries_page_with_csv_export, do: Stats.fetch_entries_page() |> Exporter.to_csv_stream() |> Enum.to_list()
  defp fetch_entries_page_with_player_filter, do: Stats.fetch_entries_page(filters: %{player: " IV"})
  defp fetch_entries_page_ordered_by_total_rushing_yards, do: Stats.fetch_entries_page(order_by: {:asc, :total_rushing_yards})
  defp fetch_entries_page_ordered_by_longest_rush, do: Stats.fetch_entries_page(order_by: {:asc, :longest_rush})
  defp fetch_entries_page_ordered_by_total_rushing_touchdowns, do: Stats.fetch_entries_page(order_by: {:asc, :total_rushing_touchdowns})
end

NFLRushing.GeneralBenchmarks.run()

# Example run:
#
# Operating System: macOS
# CPU Information: Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
# Number of Available Cores: 12
# Available memory: 16 GB
# Elixir 1.12.3
# Erlang 24.1.2
#
# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 0 ns
# parallel: 1
# inputs: none specified
# Estimated total run time: 1.40 min
#
# Benchmarking fetch_entries_page/1 ordered by longest rush...
# Benchmarking fetch_entries_page/1 ordered by total rushing touchdowns...
# Benchmarking fetch_entries_page/1 ordered by total rushing yards...
# Benchmarking fetch_entries_page/1 with csv export...
# Benchmarking fetch_entries_page/1 with no params...
# Benchmarking fetch_entries_page/1 with player filter...
# Benchmarking list_entries/1 ordered by longest rush...
# Benchmarking list_entries/1 ordered by total rushing touchdowns...
# Benchmarking list_entries/1 ordered by total rushing yards...
# Benchmarking list_entries/1 with csv export...
# Benchmarking list_entries/1 with no params...
# Benchmarking list_entries/1 with player filter...
#
# Name                                                               ips        average  deviation         median         99th %
# list_entries/1 with player filter                                 7.61      131.46 ms     ±6.58%      131.98 ms      148.15 ms
# fetch_entries_page/1 with player filter                           5.05      198.15 ms     ±2.76%      197.77 ms      209.41 ms
# fetch_entries_page/1 with no params                               1.68      594.82 ms     ±0.89%      596.40 ms      599.94 ms
# fetch_entries_page/1 with csv export                              1.67      598.61 ms     ±0.93%      599.23 ms      610.13 ms
# fetch_entries_page/1 ordered by total rushing yards               1.64      608.00 ms     ±1.54%      610.32 ms      618.50 ms
# fetch_entries_page/1 ordered by longest rush                      1.64      608.45 ms     ±0.92%      609.51 ms      617.77 ms
# fetch_entries_page/1 ordered by total rushing touchdowns          1.64      610.22 ms     ±1.58%      609.67 ms      624.39 ms
# list_entries/1 ordered by longest rush                            0.28     3513.58 ms     ±0.80%     3513.58 ms     3533.33 ms
# list_entries/1 with no params                                     0.27     3645.84 ms     ±0.79%     3645.84 ms     3666.16 ms
# list_entries/1 ordered by total rushing yards                     0.27     3670.30 ms     ±0.27%     3670.30 ms     3677.26 ms
# list_entries/1 ordered by total rushing touchdowns                0.27     3709.57 ms     ±2.39%     3709.57 ms     3772.33 ms
# list_entries/1 with csv export                                   0.143     6994.34 ms     ±0.00%     6994.34 ms     6994.34 ms
#
# Comparison:
# list_entries/1 with player filter                                 7.61
# fetch_entries_page/1 with player filter                           5.05 - 1.51x slower +66.69 ms
# fetch_entries_page/1 with no params                               1.68 - 4.52x slower +463.35 ms
# fetch_entries_page/1 with csv export                              1.67 - 4.55x slower +467.15 ms
# fetch_entries_page/1 ordered by total rushing yards               1.64 - 4.62x slower +476.53 ms
# fetch_entries_page/1 ordered by longest rush                      1.64 - 4.63x slower +476.98 ms
# fetch_entries_page/1 ordered by total rushing touchdowns          1.64 - 4.64x slower +478.75 ms
# list_entries/1 ordered by longest rush                            0.28 - 26.73x slower +3382.11 ms
# list_entries/1 with no params                                     0.27 - 27.73x slower +3514.38 ms
# list_entries/1 ordered by total rushing yards                     0.27 - 27.92x slower +3538.84 ms
# list_entries/1 ordered by total rushing touchdowns                0.27 - 28.22x slower +3578.11 ms
# list_entries/1 with csv export                                   0.143 - 53.20x slower +6862.87 ms
