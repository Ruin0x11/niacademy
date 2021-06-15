defmodule NiacademyWeb.StartSessionController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      regimens: Niacademy.Db.list_regimens,
      image_categories: Niacademy.Images.list_categories)
  end
end
