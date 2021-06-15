defmodule Niacademy.Images do
  def scan do
    load_sub_dir = fn sub_dir -> {Path.basename(sub_dir), Path.wildcard(Path.join(sub_dir, "*"))} end
    load_main_dir = fn main_dir -> {Path.basename(main_dir), Enum.map(Path.wildcard(Path.join(main_dir, "*")), load_sub_dir) |> Enum.into(%{})} end

    images_dir = Application.get_env(:niacademy, :images_dir)

    Enum.map(Path.wildcard(Path.join(images_dir, "*")), load_main_dir) |> Enum.into(%{})
  end

  def list_for_category(category) do
    with data <- Niacademy.Images.Cache.get do
      case String.split(category, "/") do
        [x] -> data[x] |> Map.values |> Enum.flat_map(fn x -> x end)
        [x1, x2] -> data[x1][x2]
        _ -> raise "Invalid category '#{category}'"
      end
    end
  end

  def list_for_categories(categories) do
    case categories do
      [] -> with data <- Niacademy.Images.Cache.get do
              data |> Map.values |> Enum.flat_map(fn x -> x |> Map.values |> Enum.flat_map(fn y -> y end) end)
            end
      xs -> Enum.flat_map(xs, fn x -> Niacademy.Images.list_for_category x end)
    end
  end

  def list_categories do
    images = Niacademy.Images.Cache.get
    categories = images |> Map.keys
    subcategories = images |> Enum.flat_map(fn {key, value} -> Enum.map(value, fn {subkey, _} -> "#{key}/#{subkey}" end) end)
    Enum.concat(categories, subcategories)
  end
end
