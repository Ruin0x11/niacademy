defmodule Niacademy.Activity do
  def resolve(id, args, regimen_id) do
    Niacademy.Db.get_activity(id) |> do_resolve(args) |> Map.put("regimenId", regimen_id)
  end

  defp do_resolve(%{"source" => %{"type" => "Custom"}} = activity, args) do
    images = Niacademy.Images.list_for_categories(args[:categories])
    image_file = images |> Enum.random
    extra = %{"imageFiles" => [image_file]}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve(%{"source" => %{"type" => "Freeform"}} = activity, _args) do
    activity
  end

  defp do_resolve(%{"source" => %{"type" => "File", "data" => data}} = activity, _args) do
    extra = %{"imageFiles" => data}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve(%{"source" => %{"type" => "Categories", "data" => data}} = activity, _args) do
    images = Niacademy.Images.list_for_categories(data["categories"])
    image_files = images |> Enum.take_random(data["imageCount"])
    image_files = data["files"] |> Enum.concat(image_files)
    extra = %{"imageFiles" => image_files}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve(activity, _args) do
    raise "Invalid activity #{activity}"
  end
end
