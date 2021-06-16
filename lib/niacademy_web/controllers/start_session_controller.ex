defmodule NiacademyWeb.StartSessionController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      regimens: Niacademy.Db.list_regimens,
      image_categories: Niacademy.Images.list_categories,
      presets: Niacademy.Db.list_presets |> Map.put("(none)", %{"humanName" => "(none)"}),
      current_preset_id: "fig_dab2_3")
  end
end
