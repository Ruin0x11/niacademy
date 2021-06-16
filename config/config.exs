# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :niacademy,
  ecto_repos: [Niacademy.Repo],
  images_dir: "lib/images",
  regimens_file: "config/regimens.yml",
  global_user: "nonbirithm"

config :niacademy, :basic_auth, username: "nonbirithm", password: "dood"

# Configures the endpoint
config :niacademy, NiacademyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3QEXeI88NziIvJ05l5jVs3/0XGTDNURc1a+LnbVKZqIfV7W801b2gh6U0OaUZ6W6",
  render_errors: [view: NiacademyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Niacademy.PubSub,
  live_view: [signing_salt: "BnyM49cv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
