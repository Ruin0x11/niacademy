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
       display_seconds: 0,
       loaded: false
     )}
  end

  @impl true
  def handle_params(%{"session_id" => session_id}, _val, socket) do
    session = Session.get!(session_id)
    session = %{session | activities: Jason.decode!(session.activities)}
    activity = session.activities |> Enum.at(session.position)

    {:noreply, assign(socket,
       mode: :paused,
       session: session,
       activity: activity,
       remaining: 0,
       display_minutes: 0,
       display_seconds: 0,
       loaded: false)
    }
  end

  @impl true
  def handle_event("start", _, socket) do
    {:noreply,
     socket
     |> activate()}
  end

  @impl true
  def handle_event("content_loaded", _, socket) do
    IO.puts("Loaded content!")
    handle_event("start", %{}, socket |> assign(loaded: true))
  end

  @impl true
  def handle_info(:tick, socket) do
    update_socket = update_timer(socket)

    if update_socket.assigns.mode == :finished do
      handle_event("prev", %{}, update_socket)
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

    set_timer(socket, remaining - 0)
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

  def set_position(%{assigns: %{session: session}} = socket, delta) do
    with session <- Session.get!(session.id) do
      if session.position + delta < 0 do
                            raise "Can't go backward here."
                            else
                              case Session.update(session, %{position: session.position + delta}) do
                                {:ok, session} ->
                                  {:noreply, socket |> push_redirect(to: Routes.activity_live_path(socket, :show, session.id))}
                                {:error, %Ecto.Changeset{} = changeset} ->
                                  raise changeset
                              end
      end
    end
  end

  @impl true
  def handle_event("next", _, socket) do
    IO.puts("AAA")
    set_position(socket, 1)
  end

  @impl true
  def handle_event("prev", _, socket) do
    set_position(socket, -1)
  end

end
