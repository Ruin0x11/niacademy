defmodule NiacademyWeb.ControllerHelpers do
  import Plug.Conn
  import Phoenix.Controller

  def render_error(conn, status, assigns \\ []) do
    conn
    |> put_status(status)
    |> put_layout(false)
    |> put_view(NiacademyWeb.ErrorView)
    |> render(:"#{status}", assigns)
    |> halt()
  end
end
