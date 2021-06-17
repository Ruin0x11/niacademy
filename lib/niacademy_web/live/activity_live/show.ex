defmodule NiacademyWeb.ActivityLive.Show do
  use Phoenix.LiveView, layout: {NiacademyWeb.LayoutView, "live.html"}
  alias Niacademy.Session
  alias NiacademyWeb.ActivityView
  alias NiacademyWeb.Router.Helpers, as: Routes
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Niacademy.LiveMonitor.monitor(self(), __MODULE__, %{id: socket.id})
    {:ok,
     assign(socket,
       mode: :paused,
       session: %Session{},
       remaining: 0,
       total: 0,
       activity_count: 0,
       percent_elapsed: 0,
       display_minutes: 0,
       display_seconds: 0,
       unbounded: false,
       loaded: false
     )}
  end

  # called by LiveMonitor
  def unmount(reason, %{id: id}) do
    Logger.debug("View #{id} unmounted: #{inspect(reason)}")
    with {:shutdown, _} <- reason do
      Logger.warning("Halting tracking for session.")
      Niacademy.Tracking.stop_tracking_active()
    end
    :ok
  end

  @impl true
  def handle_params(%{"session_id" => session_id}, _val, socket) do
    session = Session.get!(session_id)
    activities = Jason.decode!(session.activities)
    session = %{session | activities: activities}
    activity = session.activities |> Enum.at(session.position)

    {:noreply, assign(socket,
       mode: :paused,
       session: session,
       activity: activity,
       activity_count: Enum.count(activities),
       remaining: 0,
       total: 0,
       percent_elapsed: 0,
       display_minutes: 0,
       display_seconds: 0,
       unbounded: activity["unboundedDuration"],
       loaded: false)
    }
  end

  def set_position(%{assigns: %{session: session, activity_count: activity_count}} = socket, delta) do
    with session <- Session.get!(session.id) do
      if session.position + delta < 0 do
                            raise "Can't go backward here."
      end

      finished = session.position + delta >= activity_count

      if finished && session.project_type != :none && !session.finished do
        {:ok, _} = Niacademy.Db.increment_preset_position(session.project_type)
        Niacademy.Jobs.TrackerTimeout.cancel()
        Niacademy.Tracking.stop_tracking_active()
      end

      case Session.update(session, %{position: session.position + delta, finished: finished}) do
        {:ok, session} ->
          {:noreply, socket |> push_redirect(to: Routes.activity_live_path(socket, :show, session.id))}
        {:error, %Ecto.Changeset{} = changeset} ->
          raise changeset
      end
    end
  end

  @impl true
  def handle_event("start", _, socket) do
    {:noreply,
     socket
     |> activate()}
  end

  @impl true
  def handle_event("content_loaded", _, socket) do
    Logger.debug("Loaded content!")
    handle_event("start", %{}, socket |> assign(loaded: true))
  end

  @impl true
  def handle_event("next", _, socket) do
    set_position(socket, 1)
  end

  @impl true
  def handle_event("prev", _, socket) do
    set_position(socket, -1)
  end

  @impl true
  def handle_info(:tick, socket) do
    update_socket = update_timer(socket)

    if update_socket.assigns.mode == :finished do
      handle_event("next", %{}, update_socket)
    else
      {:noreply, update_socket}
    end
  end

  defp update_timer(%{assigns: %{remaining: 0, mode: :active, timer: timer, unbounded: unbounded}} = socket) do
    if unbounded do
      decrement(socket)
    else
      {:ok, _} = :timer.cancel(timer)
      assign(socket, mode: :finished, timer: nil)
    end
  end

  defp update_timer(socket) do
    decrement(socket)
  end

  defp decrement(socket) do
    if socket.assigns.loaded do
      %{assigns: %{remaining: remaining}} = socket

      set_timer(socket, remaining - 1)
    else
      socket
    end
  end

  defp set_timer(socket, seconds) do
    %{assigns: %{total: total}} = socket

    display_minutes = div(seconds, 60)
    display_seconds = rem(seconds, 60)
    percent = ((total - seconds) / total) * 100.0

    assign(socket,
      remaining: seconds,
      percent_elapsed: percent,
      display_minutes: display_minutes,
      display_seconds: display_seconds)
  end

  @impl true
  def render(assigns) do
    if assigns.activity do
      ActivityView.render("show.html", assigns)
    else
      ActivityView.render("show_finished.html", assigns)
    end
  end

  defp activate(%{assigns: %{session: session, activity: activity, activity_count: activity_count, mode: :paused}} = socket) do
    {:ok, timer} = :timer.send_interval(1000, :tick)

    total_seconds = (activity["durationMinutes"]) * 60

    activity = activity["activity"]
    description = "Activity: #{activity["humanName"]} (#{session.position+1}/#{activity_count})"
    tags = [
      "activity:#{activity["id"]}",
      "preset:#{session.preset_id || "<none>"}",
      "regimen:#{activity["regimenId"]}"
    ]

    project_type =
      case session.project_type do
        :none -> activity["projectType"] |> String.downcase |> String.to_atom
        type -> type
      end

    project_type
    |> Niacademy.Tracking.project_type_to_project
    |> Niacademy.Tracking.start_tracking(description, tags)
    |> IO.inspect

    Niacademy.Jobs.TrackerTimeout.persist(total_seconds * 1.5)

    socket |> assign(mode: :active, total: total_seconds, timer: timer) |> set_timer(total_seconds)
  end

  defp activate(socket) do
    socket
  end
end
