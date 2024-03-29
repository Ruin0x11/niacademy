defmodule NiacademyWeb.Router do
  use NiacademyWeb, :router
  import Phoenix.LiveView.Router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :basic_auth, Application.compile_env(:niacademy, :basic_auth)
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {NiacademyWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NiacademyWeb do
    pipe_through :browser

    get "/", StartController, :index
    get "/start_session", StartSessionController, :index
    resources "/sessions", SessionController
    live "/activity/show/:session_id", ActivityLive.Show, :show, as: :activity_live
    post "/activity/create", ActivityController, :create
    post "/activity/create_from_preset", ActivityController, :create_from_preset
    post "/activity/set_preset_position", ActivityController, :set_preset_position
    get "/image", ImageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", NiacademyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: NiacademyWeb.Telemetry
    end
  end
end
