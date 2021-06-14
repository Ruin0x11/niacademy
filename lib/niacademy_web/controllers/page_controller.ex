defmodule NiacademyWeb.PageController do
  use NiacademyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
