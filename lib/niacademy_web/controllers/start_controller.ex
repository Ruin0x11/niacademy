defmodule NiacademyWeb.StartController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    {_, preset_id} = Niacademy.Db.get_current_preset
    preset_name = Niacademy.Db.list_presets[preset_id]["humanName"]

    render(conn, "index.html",
      preset_id: preset_id,
      preset_name: preset_name)
  end
end
