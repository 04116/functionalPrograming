import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :smartcity, Smartcity.Repo,
  database: Path.expand("../smartcity_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smartcity_web, SmartcityWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "pF0a85rSbnJVIqd8xrqBGO6R9bLcTWilzCDYmC/7iH7kN+2DWs4TnZCJX0ldJWoL",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails
config :smartcity, Smartcity.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
