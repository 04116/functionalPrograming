defmodule Smartcity.Repo do
  use Ecto.Repo,
    otp_app: :smartcity,
    adapter: Ecto.Adapters.SQLite3
end
