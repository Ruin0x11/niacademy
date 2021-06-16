defmodule Niacademy.Jobs.TrackerTimeout do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{duration: 0})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:persist, %{duration: new_duration}}, state) do
    Logger.debug("About to persist: #{new_duration}sec")

    {:noreply, state |> schedule_timeout(new_duration)}
  end

  @impl true
  def handle_cast(:cancel, %{ timer: _timer } = state) do
    Logger.debug("About to cancel")

    {:noreply, state |> do_cancel()}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:noreply, timeout(state)}
  end

  def persist(duration) do
    GenServer.cast(__MODULE__, {:persist, %{duration: duration}})
  end

  def cancel do
    GenServer.cast(__MODULE__, :cancel)
  end

  defp do_cancel(%{ timer: timer } = state) do
    Process.cancel_timer(timer)
    Map.delete(state, :timer)
  end

  defp timeout(state) do
    Logger.warning("Timed out tracking.")
    Niacademy.Tracking.stop_tracking_active()
    do_cancel(state)
  end

  defp schedule_timeout(state, duration) do
    %{state | duration: duration, timer: Process.send_after(self(), :timeout, duration * 1000)}
  end
end
