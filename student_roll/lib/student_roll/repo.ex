defmodule StudentRoll.Repo do
  use Ecto.Repo,
    otp_app: :student_roll,
    adapter: Ecto.Adapters.Postgres
end
