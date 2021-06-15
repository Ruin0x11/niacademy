defmodule NiacademyWeb.ActivityController do
  use NiacademyWeb, :controller
  alias Niacademy.Session

  def create(conn, params) do
    with session_params <- Niacademy.Db.create_session_changeset(params),
         {:ok, %Session{} = session} <- Session.create(session_params) do
      conn
      |> redirect(to: Routes.activity_live_path(conn, :show, session.id))
    end
  end
end
