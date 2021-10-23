import Config

config :nfl_rushing,
  namespace: NFLRushing,
  ecto_repos: [NFLRushing.Repo],
  generators: [binary_id: true]

config :nfl_rushing, NFLRushingWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NFLRushingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NFLRushing.PubSub,
  live_view: [signing_salt: "mWn/lekL"]

config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
