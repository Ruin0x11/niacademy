defmodule NiacademyWeb.ImageController do
  use NiacademyWeb, :controller

  def show(conn, %{"image_file" => image_file}) do
    with relative_path <- Path.expand(image_file) |> Path.relative_to_cwd,
         images_dir <- Application.get_env(:niacademy, :images_dir),
         real_path <- Path.join(images_dir, relative_path) do
      if File.exists?(real_path) do
        conn
        |> send_download({:file, real_path}, disposition: :inline)
      else
        conn
        |> render_error(404)
      end
    end
  end
end
