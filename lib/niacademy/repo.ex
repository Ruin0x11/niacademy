defmodule Niacademy.Repo do
  use Ecto.Repo,
    otp_app: :niacademy,
    adapter: Ecto.Adapters.Postgres
end
