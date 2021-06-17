defmodule NiacademyWeb.StartController do
  use NiacademyWeb, :controller
  alias Niacademy.Tracking

  defp clamp(n, min, _max) when n<min, do: min
  defp clamp(n, _min, max) when n>max, do: max
  defp clamp(n, _min, _max), do: n

  def index(conn, _params) do
    Tracking.stop_tracking_active

    {_, preset_id} = Niacademy.Db.get_current_preset
    preset = Niacademy.Db.list_presets[preset_id]
    project_type = Niacademy.Db.get_optimal_project()

    %{tutorial: tutorial, free: free, ratio: ratio} = Niacademy.Tracking.Cache.get_stats()

    percentage = clamp((tutorial / (tutorial + free)) * 100, 0, 100)

    render(conn, "index.html",
      preset_id: preset_id,
      preset: preset,
      tutorial_draw_time: tutorial,
      free_draw_time: free,
      draw_time_percentage: percentage,
      project_type: project_type)
  end
end
