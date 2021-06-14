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

  def set_position(conn, session_id, delta) do
    with session <- Session.get!(session_id) do
      if session.position + delta < 0 do
                            conn
                            |> render_error(400)
                            else
                              case Session.update(session, %{position: session.position + delta}) do
                                {:ok, session} ->
                                  conn
                                  |> redirect(to: Routes.activity_live_path(conn, :show, session.id))
                                {:error, %Ecto.Changeset{} = changeset} ->
                                  conn
                                  |> put_status(:bad_request)
                                  |> render(NiacademyWeb.ChangesetView, "error.json", changeset: changeset)
                              end
      end
    end
  end

  def next(conn, %{"session_id" => session_id}) do
    set_position(conn, session_id, 1)
  end

  def prev(conn, %{"session_id" => session_id}) do
    set_position(conn, session_id, -1)
  end
end
