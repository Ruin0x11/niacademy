defmodule NiacademyWeb.StartController do
  use NiacademyWeb, :controller
  alias Niacademy.Tracking

  def index(conn, _params) do
    Tracking.stop_tracking_active

    {_, preset_id} = Niacademy.Db.get_current_preset
    preset = Niacademy.Db.list_presets[preset_id]
    project_type = Niacademy.Db.get_optimal_project()

    %{tutorial: tutorial, free: free} = Niacademy.Tracking.Cache.get_stats()

    render(conn, "index.html",
      preset_id: preset_id,
      preset: preset,
      tutorial_draw_time: tutorial,
      free_draw_time: free,
      project_type: project_type)
  end
end
