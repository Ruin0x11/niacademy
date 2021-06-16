defmodule Niacademy.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    Niacademy.ProjectTypeEnum.create_type
    create table(:sessions) do
      add :regimen_ids, {:array, :string}
      add :position, :integer
      add :activities, :text
      add :show_controls, :boolean
      add :finished, :boolean
      add :preset_id, :string
      add :project_type, Niacademy.ProjectTypeEnum.type()

      timestamps()
    end
  end
end
