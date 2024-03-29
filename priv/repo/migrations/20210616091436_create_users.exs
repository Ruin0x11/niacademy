defmodule Niacademy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :preset_position_tutorial, :integer
      add :preset_position_free, :integer
      add :username, :string

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
