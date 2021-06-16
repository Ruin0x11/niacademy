defmodule Niacademy.Jobs.CleanSessions do
  use GenServer
  import Ecto.Query, warn: false
  alias Niacademy.Repo
  alias Niacademy.Session
  require Logger

  @interval 24 * 60 * 60 * 1000

  def start_link(_opts) do
    Logger.info("Starting clean sessions job.")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    clean_sessions()
    schedule_work()
    {:noreply, state}
  end

  defp clean_sessions do
    with date <- Timex.now |> Timex.shift(days: -7) ,
         {deleted, _} = Session |> where([s], s.inserted_at < ^date) |> Repo.delete_all do
      Logger.info("Cleaned #{deleted} old sessions.")
    end
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end
end
