defmodule NiacademyWeb.ActivityController do
  use NiacademyWeb, :controller
  alias Niacademy.Session

  def create(conn, %{"regimen_id" => regimen_id} = params) do
    with session_params <- Niacademy.Db.create_session_changeset(regimen_id, params),
         {:ok, %Session{} = session} <- Session.create(session_params) do
      conn
      |> redirect(to: Routes.activity_live_path(conn, :show, session.id))
    end
  end

  def show(conn, %{"session_id" => session_id}) do
    with session <- Session.get!(session_id),
         json <- Jason.decode!(session.activities),
         activity <- Enum.at(json, session.position) do
      case activity do
        nil -> if session.position >= Enum.count json do
          render(conn, "show_finished.html",
            activity_id: activity["activityId"])
        else
          conn
          |> render_error(400)
        end
          render(conn, "show.html",
            position: session.position,
            activity_id: activity["activityId"],
            duration: activity["durationMinutes"])
      end
    end
  end
end
