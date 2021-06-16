defmodule NiacademyWeb.StartSessionController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    presets = Niacademy.Db.list_presets
    {preset_pos, preset_id} = Niacademy.Db.get_current_preset
    render(conn, "index.html",
      regimens: Niacademy.Db.list_regimens,
      image_categories: Niacademy.Images.list_categories,
      presets: presets |> Map.put("(none)", %{"humanName" => "(none)"}),
      preset_order_tutorial: Niacademy.Db.get_preset_order(:tutorial) |> Enum.map(& presets[&1]),
      preset_order_free: Niacademy.Db.get_preset_order(:free) |> Enum.map(& presets[&1]),
      current_preset_id: preset_id,
      current_preset_pos: preset_pos)
  end
end
