defmodule NiacademyWeb.ImageController do
  use NiacademyWeb, :controller

  def show(conn, %{"image_file" => image_file}) do
    with absolute_path <- Path.expand(image_file) |> Path.relative_to_cwd,
         images_dir <- Application.get_env(:niacademy, :images_dir) do
      if String.starts_with?(absolute_path, images_dir) do
        conn
        |> send_download({:file, absolute_path}, disposition: :inline)
      else
        conn
        |> render_error(404)
      end
    end
  end
end
