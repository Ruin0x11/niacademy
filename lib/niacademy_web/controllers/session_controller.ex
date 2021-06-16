defmodule NiacademyWeb.SessionController do
  use NiacademyWeb, :controller

  alias Niacademy.Session

  action_fallback NiacademyWeb.FallbackController

  def index(conn, _params) do
    sessions = Session.list()
    render(conn, "index.json", sessions: sessions)
  end

  def create(conn, session_params) do
    with {:ok, %Session{} = session} <- Session.create(session_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.session_path(conn, :show, session))
      |> render("show.json", session: session)
    end
  end

  def show(conn, %{"id" => id}) do
    session = Session.get!(id)
    render(conn, "show.json", session: session)
  end

  def update(conn, %{"id" => id, "session" => session_params}) do
    session = Session.get!(id)

    with {:ok, %Session{} = session} <- Session.update(session, session_params) do
      render(conn, "show.json", session: session)
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Session.get!(id)

    with {:ok, %Session{}} <- Session.delete(session) do
      send_resp(conn, :no_content, "")
    end
  end
end
