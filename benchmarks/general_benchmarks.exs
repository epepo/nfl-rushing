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
        "list_entries/1 with encoding" => &list_entries_with_encoding/0,
        "list_entries/1 with player filter" => &list_entries_with_player_filter/0,
        "list_entries/1 ordered by total rushing yards" => &list_entries_ordered_by_total_rushing_yards/0,
        "list_entries/1 ordered by longest rush" => &list_entries_ordered_by_longest_rush/0,
        "list_entries/1 ordered by total rushing touchdowns" => &list_entries_ordered_by_total_rushing_touchdowns/0,
        "fetch_entries_page/1 with no params" => &fetch_entries_page_no_params/0,
        "fetch_entries_page/1 with encoding" => &fetch_entries_page_with_encoding/0,
        "fetch_entries_page/1 with player filter" => &fetch_entries_page_with_player_filter/0,
        "fetch_entries_page/1 ordered by total rushing yards" => &fetch_entries_page_ordered_by_total_rushing_yards/0,
        "fetch_entries_page/1 ordered by longest rush" => &fetch_entries_page_ordered_by_longest_rush/0,
        "fetch_entries_page/1 ordered by total rushing touchdowns" => &fetch_entries_page_ordered_by_total_rushing_touchdowns/0,
      }
    )

    Sandbox.stop_owner(pid)
  end

  defp list_entries_no_params, do: Stats.list_entries()
  defp list_entries_with_encoding, do: Exporter.to_csv(Stats.list_entries())
  defp list_entries_with_player_filter, do: Stats.list_entries(filters: %{player: " IV"})
  defp list_entries_ordered_by_total_rushing_yards, do: Stats.list_entries(order_by: {:asc, :total_rushing_yards})
  defp list_entries_ordered_by_longest_rush, do: Stats.list_entries(order_by: {:asc, :longest_rush})
  defp list_entries_ordered_by_total_rushing_touchdowns, do: Stats.list_entries(order_by: {:asc, :total_rushing_touchdowns})

  defp fetch_entries_page_no_params, do: Stats.fetch_entries_page()
  defp fetch_entries_page_with_encoding, do: Exporter.to_csv(Stats.fetch_entries_page())
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
# Benchmarking fetch_entries_page/1 with encoding...
# Benchmarking fetch_entries_page/1 with no params...
# Benchmarking fetch_entries_page/1 with player filter...
# Benchmarking list_entries/1 ordered by longest rush...
# Benchmarking list_entries/1 ordered by total rushing touchdowns...
# Benchmarking list_entries/1 ordered by total rushing yards...
# Benchmarking list_entries/1 with encoding...
# Benchmarking list_entries/1 with no params...
# Benchmarking list_entries/1 with player filter...
#
# Name                                                               ips        average  deviation         median         99th %
# fetch_entries_page/1 with no params                              21.57       46.36 ms     ±2.69%       46.37 ms       50.12 ms
# fetch_entries_page/1 with encoding                               21.28       47.00 ms     ±3.44%       47.04 ms       51.81 ms
# fetch_entries_page/1 ordered by total rushing touchdowns         20.51       48.75 ms     ±3.34%       48.84 ms       55.78 ms
# fetch_entries_page/1 ordered by total rushing yards              20.44       48.91 ms     ±4.65%       48.59 ms       61.91 ms
# fetch_entries_page/1 ordered by longest rush                     20.40       49.01 ms     ±3.31%       48.87 ms       53.99 ms
# list_entries/1 with player filter                                13.86       72.13 ms    ±10.82%       69.59 ms       96.19 ms
# fetch_entries_page/1 with player filter                          12.72       78.61 ms     ±3.37%       78.60 ms       85.34 ms
# list_entries/1 ordered by total rushing yards                     0.29     3401.97 ms     ±0.33%     3401.97 ms     3409.95 ms
# list_entries/1 ordered by total rushing touchdowns                0.29     3448.68 ms     ±0.78%     3448.68 ms     3467.63 ms
# list_entries/1 with no params                                     0.26     3891.28 ms    ±13.24%     3891.28 ms     4255.69 ms
# list_entries/1 ordered by longest rush                            0.25     3953.06 ms    ±17.62%     3953.06 ms     4445.48 ms
# list_entries/1 with encoding                                     0.145     6898.77 ms     ±0.00%     6898.77 ms     6898.77 ms
#
# Comparison:
# fetch_entries_page/1 with no params                              21.57
# fetch_entries_page/1 with encoding                               21.28 - 1.01x slower +0.64 ms
# fetch_entries_page/1 ordered by total rushing touchdowns         20.51 - 1.05x slower +2.39 ms
# fetch_entries_page/1 ordered by total rushing yards              20.44 - 1.06x slower +2.56 ms
# fetch_entries_page/1 ordered by longest rush                     20.40 - 1.06x slower +2.66 ms
# list_entries/1 with player filter                                13.86 - 1.56x slower +25.77 ms
# fetch_entries_page/1 with player filter                          12.72 - 1.70x slower +32.26 ms
# list_entries/1 ordered by total rushing yards                     0.29 - 73.39x slower +3355.62 ms
# list_entries/1 ordered by total rushing touchdowns                0.29 - 74.40x slower +3402.33 ms
# list_entries/1 with no params                                     0.26 - 83.94x slower +3844.92 ms
# list_entries/1 ordered by longest rush                            0.25 - 85.28x slower +3906.70 ms
# list_entries/1 with encoding                                     0.145 - 148.82x slower +6852.41 ms
