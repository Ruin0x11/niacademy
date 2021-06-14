defmodule NiacademyWeb.SessionView do
  use NiacademyWeb, :view
  alias NiacademyWeb.SessionView

  def render("index.json", %{sessions: sessions}) do
    %{data: render_many(sessions, SessionView, "session.json")}
  end

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{id: session.id,
      regimen_id: session.regimen_id,
      position: session.position,
      activities: Jason.decode!(session.activities),
      categories: session.categories}
  end
end
