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

  def create_from_preset(conn, %{"preset_id" => preset_id, "type" => type}) do
    with session_params <- Niacademy.Db.create_session_changeset_from_preset(preset_id, String.to_atom(type)),
         {:ok, %Session{} = session} <- Session.create(session_params) do
      conn
      |> redirect(to: Routes.activity_live_path(conn, :show, session.id))
    end
  end

  def set_preset_position(conn, %{"preset_position" => preset_position, "type" => type}) do
    with {pos, _} <- Integer.parse(preset_position),
         {:ok, _} <- Niacademy.Db.set_preset_position(pos, String.to_atom(type)) do
      conn
      |> put_flash(:info, "Updated successfully.")
      |> redirect(to: Routes.start_path(conn, :index))
    end
  end
end
