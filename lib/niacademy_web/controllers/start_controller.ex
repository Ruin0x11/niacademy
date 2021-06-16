defmodule NiacademyWeb.StartController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    preset_id = "fig_dab2_3"
    preset_name = Niacademy.Db.list_presets[preset_id]["humanName"]

    render(conn, "index.html",
      preset_id: preset_id,
      preset_name: preset_name)
  end
end
