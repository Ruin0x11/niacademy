defmodule Niacademy.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :regimen_id, :string
      add :position, :integer
      add :activities, :text
      add :categories, {:array, :string}
      add :show_controls, :boolean

      timestamps()
    end
  end
end
