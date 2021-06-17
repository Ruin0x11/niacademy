defmodule Niacademy.Tracking do
  require Togglex
  require Logger

  def client do
    with token <- Application.get_env(:niacademy, :toggl_api_token) do
      Togglex.Client.new(%{access_token: token}, :api)
    end
  end

  def workspace do
    with workspace_name <- Application.get_env(:niacademy, :toggl_workspace) do
      client()
      |> Togglex.Api.Workspaces.list
      |> Enum.find(fn workspace -> workspace[:name] == workspace_name end)
    end
  end

  defp find_project(project_name) do
    Niacademy.Tracking.Cache.get_projects()
    |> Enum.find(fn project -> project[:name] == project_name end)
    |> Map.get(:id)
  end

  def free_draw_project do
    Application.get_env(:niacademy, :toggl_free_draw_project) |> find_project
  end

  def tutorial_draw_project do
    Application.get_env(:niacademy, :toggl_tutorial_draw_project) |> find_project
  end

  def project_time_entries(project_id, since) do
    with start_date <- since |> DateTime.to_iso8601,
         end_date <- Timex.now |> DateTime.to_iso8601 do
      client()
      |> Togglex.Api.TimeEntries.list(start_date: start_date, end_date: end_date)
      |> Enum.filter(fn time_entry -> time_entry[:pid] == project_id end)
    end
  end

  def since_time, do: Timex.now |> Timex.shift(Application.get_env(:niacademy, :toggl_tracking_interval))

  def project_time_spent(project_id, since \\ since_time()) do
    project_time_entries(project_id, since)
    |> Enum.map(& &1[:duration])
    |> Enum.sum
  end

  def tutorial_to_free_ratio(tutorial_draw_time, free_draw_time) do
    cond do
      tutorial_draw_time == 0 -> 1 / 100  # do tutorial draw next
      free_draw_time == 0     -> 100 / 1  # do free draw next
      true                    -> tutorial_draw_time / free_draw_time
    end
  end

  def active_project do
    case client() |> Togglex.Api.TimeEntries.current |> Map.get(:data) do
      nil -> %{type: :none, time_entry: nil}
      time_entry ->
        with free <- free_draw_project(),
             tutorial <- tutorial_draw_project() do
          type = case time_entry[:pid] do
            ^free -> :free
            ^tutorial -> :tutorial
            _ -> :none
          end
          %{type: type, time_entry: time_entry}
        end
    end
  end

  def project_type_to_project(project_type) do
    case project_type do
      :tutorial -> tutorial_draw_project()
      :free -> free_draw_project()
      x -> raise "Invalid project type #{x}"
    end
  end

  def start_tracking(project_id, description \\ "niacademy", tags \\ []) do
    Logger.debug("Tracking: #{project_id}  #{description}  #{tags}")
    Niacademy.Tracking.Cache.invalidate()
    with data <- %{pid: project_id, description: description, tags: tags} do
      client()
      |> Togglex.Api.TimeEntries.start(data)
    end
  end

  def stop_tracking_active do
    Logger.warning("Stopping active tracking.")
    case client() |> Togglex.Api.TimeEntries.current |> Map.get(:data) do
      nil -> nil
      time_entry -> client() |> Togglex.Api.TimeEntries.stop(time_entry[:id])
    end
  end
end
