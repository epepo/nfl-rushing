# NFLRushing

This is an implementation of theScore's technical challenge for candidate engineers.

The following is a description of the challenge that has been preserved as instructed, followed by a stream of consciousness description of the implementation.

## The Challenge

We have sets of records representing football players' rushing statistics. All records have the following attributes:
* `Player` (Player's name)
* `Team` (Player's team abbreviation)
* `Pos` (Player's postion)
* `Att/G` (Rushing Attempts Per Game Average)
* `Att` (Rushing Attempts)
* `Yds` (Total Rushing Yards)
* `Avg` (Rushing Average Yards Per Attempt)
* `Yds/G` (Rushing Yards Per Game)
* `TD` (Total Rushing Touchdowns)
* `Lng` (Longest Rush -- a `T` represents a touchdown occurred)
* `1st` (Rushing First Downs)
* `1st%` (Rushing First Down Percentage)
* `20+` (Rushing 20+ Yards Each)
* `40+` (Rushing 40+ Yards Each)
* `FUM` (Rushing Fumbles)

In this repo is a sample data file [`priv/repo/rushing.json`](/priv/repo/rushing.json).

### Challenge Requirements

1. Create a web app. This must be able to do the following steps
    1. Create a webpage which displays a table with the contents of [`priv/repo/rushing.json`](/priv/repo/rushing.json)
    2. The user should be able to sort the players by _Total Rushing Yards_, _Longest Rush_ and _Total Rushing Touchdowns_
    3. The user should be able to filter by the player's name
    4. The user should be able to download the sorted data as a CSV, as well as a filtered subset

2. The system should be able to potentially support larger sets of data on the order of 10k records.

3. Update the section `Installation and running this solution` in the README file explaining how to run your code

### Installation and running this solution

This solution requires the following software:

- Erlang OTP 24
- Elixir 1.12 or greater
- Postgres 12 or greater
- NodeJS 16.13

Compatible versions of Erlang and Elixir are configured via [`asdf-vm`](https://github.com/asdf-vm/asdf)'s `.tool-versions` for convenience.
Postgres is expected to be running on `localhost:5432` with `postgres:postgres` as credentials for the development environment; other environments can be configured on their respective `config/$ENV.exs` file as per Elixir's conventions.

The following commands will run an interactive IEx shell with a development server:
```sh
$ mix deps.get && npm i --prefix=assets
$ mix ecto.setup
$ iex -S mix phx.server
```

At this point the web app will be available on `localhost:4000`.

By default, `mix ecto.setup` runs the default seeds which include all data from [`priv/repo/rushing.json`](/priv/repo/rushing.json).
More entries can be generated on the development and testing environments with the following snippet:

```elixir
iex(1)> expected_entries = 200_000
200000
iex(2)> for _ <- 1..expected_entries, do: NFLRushing.StatsFixtures.entry_fixture()
[...]
```

They will have random but valid data that can be used to manually test the application.

## General Considerations

- The chosen stack for implementing this solution is the classic LiveView stack.

I'm pretty confortable with Elixir in general but LiveView is somewhat new to me. This has been a nice chance to try out what a simple LiveView application would look like, so I went with that and Tailwind CSS. Postgres is a solid choice for a general purpose database and it's very well supported by Ecto, so it made pefect sense since the application doesn't have any special data requirements.

- Field names from source data have been preserved

Considering the names are short and presumably known by possible users, they make it easier to display everything on a main table. A downside is that they're not descriptive at all, something that is mitigated by having `title` values on each table column and by using descriptive internal names (schema, database columns); this in turn makes a mapping between names in multiple contexts necessary, namely internal (application), external (`.json` importing, `csv` exporting) and display (the main table). All of this is a bit awkward and ideally I'd brainstorm a bit how to approach this with team members and stakeholders in a real app.

- Sorting by all columns is possible

This seemed to be logical given how I chose to display the data. The requirements list 3 columns but in a real product I'd guess we would either want to sort by any column or we would have some special rules or method of displaying data.

- Filtering is done with an `ILIKE` operation

This makes the code a bit awkward since we need to guard for strings that contain `%` or `_`. I've added a simple string replacement that would escape these characters but a bit more research should be done on this. Either way, using `LIKE`/`ILIKE` is not that bad since these queries can use GIN indexes, which might be useful for performance.

- Exporting uses the same filters/ordering as displaying

And that's not being explained to the user in any way. Not the best UX here but it covers the requirements.

- Deployment utilities and instructions are missing

I was planning on including a simple k8s deployment definition alongside a couple of services (service load balancing and a name entry for a Postgres server) but I'm already taking too long on this. The only thing that's set up right now is the configuration for OTP releases, but even those could have some improvements (e.g. proper Phoenix asset digestion + gzip).

## Performance Considerations

The only performance requirement mentions that the system should support data sets on the order of 10k records; by generating random entries it was clear from manual testing that the first issue would be on the browser side. The amount of rows to be displayed would cause performance issues, so the solution to that was adding some simple pagination using offsets. There's not much to comment on this other than it made the app usable again.

After that, I've spent a bit of time researching how to improve the most likely candidate for optimization: filtering by player name. The query planner always described a sequential scan to be necessary using a matching operation on each row's player. I added a simple trigram-based GIN index (with `gin_trgm_ops`) but the query planner still preffered the sequential scan for some reason. With all that in mind, I've added a simple `benchee` script with two goals:

- To compare the relative performance of the most used features in the system;
- To be able to measure if any relevant performance changes happened once a change was applied.

The script can be executed with `MIX_ENV=test mix run benchmarks/general_benchmarks.exs`.

The first point was a success since with 200,000 entries the benchmark showed that the most used operations had acceptable performance (99th %s in the 50~80ms range), including the player filter, which made me realize that it wasn't the best optimization target. The operations that took the longest were related to fetching data for exporting; all of them took 70 to 90 times longer than fetching a page of entries (taking about 4 seconds), and when considering actually exporting those 200,000 entries to CSV they would become about 150 times slower (taking about 7 seconds).

The interesting thing about the export operation is that sorting or not doesn't make much of a difference, so optimizing that is not a priority yet. The outlier really was the process of building the CSV. At this point the exporter was using `NimbleCSV.RFC4180`'s `dump_to_io_data/1`, the only extra work being mapping all entries to lists of values.

At this point I tried to implement the simplest possible CSV encoder using `iodata`, but it proved to be slower by a couple of seconds (`NimbleCSV` uses binary references in some cases and that might be one of the reasons, I need to study how and why). After that I tried to use `Repo.stream/1` to fetch the entries alongside `NimbleCSV.RFC4180.dump_to_stream/1` so we would stream everything to the client; that didn't work because `Repo.stream/1` requires a transaction to enumerate the stream items and it is not feasible to hold the database for so long. The final approach now is fetching all entries eagerly but streaming the CSV - this doesn't make the entire process any faster but the user gets the download prompt earlier, which results in a better experience, and some reduction on server's memory usage. Ideally, the front end would have indicators that the export was requested and it is being processed by the server.

Since all other interactions are good enough, I stopped looking into optimizations at this point. There's still some interesting things to study:

- If there is a way of optimizing retrieving all entries from Postgres; maybe holding a transaction to stream isn't that bad if we don't lock anything somehow.
- How NimbleCSV uses binary references and inlining might be interesting; a simplified version of it might be faster for our use case, or it might even guide the design for a NIF ([Zigler](https://hex.pm/packages/zigler) or [Rustler](https://hex.pm/packages/rustler), anyone?).
- Some indexes might make fetching entry pages faster if the sorting step could be optimized away. I need to look into this.
