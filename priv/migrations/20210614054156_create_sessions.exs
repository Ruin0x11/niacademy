defmodule Niacademy.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :regimen_ids, {:array, :string}
      add :position, :integer
      add :activities, :text
      add :show_controls, :boolean

      timestamps()
    end
  end
end
