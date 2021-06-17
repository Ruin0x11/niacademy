use Mix.Config

config :niacademy,
  # Toggl Track API token.
  toggl_api_token: "token",

  # Name of the Toggl workspace containing the projects.
  toggl_workspace: "draw",

  # Toggl projects to the hold time spent.
  toggl_free_draw_project: "free-draw",
  toggl_tutorial_draw_project: "tutorial-draw"

  # Determines how far back to count time spent for both projects.
  toggl_tracking_interval: [weeks: -1]
