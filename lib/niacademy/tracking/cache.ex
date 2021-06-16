defmodule Niacademy.Tracking.Cache do
  use Agent
  alias Niacademy.Tracking
  require Logger

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_projects do
    case Agent.get(__MODULE__, & &1) do
      %{projects: projects} -> projects
      _ -> fetch_projects()
    end
  end

  def get_stats do
    case Agent.get(__MODULE__, & &1) do
      %{stats: stats} -> stats
      _ -> calculate_stats()
    end
  end

  defp fetch_projects do
    projects = Tracking.client() |> Togglex.Api.Workspaces.projects(Tracking.workspace()[:id])
    Agent.update(__MODULE__, & Map.merge(&1, %{projects: projects}))
    Agent.get(__MODULE__, & &1[:projects])
  end

  defp calculate_stats do
    Logger.debug("Recalculating tracker stats.")

    tutorial = Tracking.tutorial_draw_project() |> Tracking.project_time_spent()
    free = Tracking.free_draw_project() |> Tracking.project_time_spent()
    ratio = Tracking.tutorial_to_free_ratio(tutorial, free)

    Agent.update(__MODULE__, & Map.merge(&1, %{stats: %{tutorial: tutorial, free: free, ratio: ratio}}))
    Agent.get(__MODULE__, & &1[:stats])
  end

  def invalidate do
    Logger.debug("Invalidating tracker stats.")
    Agent.update(__MODULE__, fn s -> Map.delete(s, :stats) end)
  end
end
