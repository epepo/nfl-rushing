import Config

config :nfl_rushing, NFLRushing.Repo,
  username: "postgres",
  password: "postgres",
  database: "nfl_rushing_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  ownership_timeout: :infinity

config :nfl_rushing, NFLRushingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "B96EmvhkqZL898todqKTOLlDAhQ++T2DprZx8XY0k3cpsUPCjSaa3wFTRo6QXZUN",
  server: false

config :logger, level: :warn

config :phoenix, :plug_init_mode, :runtime
