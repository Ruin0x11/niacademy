defmodule NiacademyWeb.ActivityLive.Show do
  use Phoenix.LiveView, layout: {NiacademyWeb.LayoutView, "live.html"}
  alias Niacademy.Session
  alias NiacademyWeb.ActivityView
  alias NiacademyWeb.Router.Helpers, as: Routes

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       mode: :paused,
       session: %Session{},
       remaining: 0,
       display_minutes: 0,
       display_seconds: 0
     )}
  end

  @impl true
  def handle_params(%{"session_id" => session_id}, _val, socket) do
    session = Session.get!(session_id)
    session = %{session | activities: Jason.decode!(session.activities)}
    activity = session.activities |> Enum.at(session.position)

    {:noreply, assign(socket, session: session, activity: activity) |> activate()}
  end

  @impl true
  def handle_event("start", _, socket) do
    {:noreply,
     socket
     |> activate()}
  end

  @impl true
  def handle_info(:tick, socket) do
    update_socket = update_timer(socket)

    if update_socket.assigns.mode == :finished do
      {:stop,
       update_socket
       |> put_flash(:info, "Finish all pomodoro!")
       |> redirect(
         to: Routes.activity_path(socket, :create)
       )}
    else
      {:noreply, update_socket}
    end
  end

  defp update_timer(%{assigns: %{remaining: 0, mode: :active, timer: timer}} = socket) do
    {:ok, _} = :timer.cancel(timer)

    assign(socket, mode: :finished, timer: nil)
  end

  defp update_timer(socket) do
    decrement(socket)
  end

  defp decrement(socket) do
    %{assigns: %{remaining: remaining}} = socket

    set_timer(socket, remaining - 1)
  end

  defp set_timer(socket, seconds) do
    display_minutes = div(seconds, 60)
    display_seconds = rem(seconds, 60)

    assign(socket, remaining: seconds, display_minutes: display_minutes, display_seconds: display_seconds)
  end

  @impl true
  def render(assigns) do
    if assigns.activity do
      ActivityView.render("show.html", assigns)
    else
      ActivityView.render("show_finished.html", assigns)
    end
  end

  defp activate(socket) do
    if socket.assigns.activity do
      {:ok, timer} = :timer.send_interval(1000, :tick)

      %{assigns: %{activity: activity}} = socket

      total_seconds = (activity |> Map.get("durationMinutes")) * 60

      socket |> set_timer(total_seconds) |> assign(mode: :active, timer: timer)
    else
      socket
    end
  end
end
