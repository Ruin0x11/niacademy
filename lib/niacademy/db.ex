defmodule Niacademy.Db do
  alias YamlElixir, as: Yaml
  def parse do
    with {:ok, yaml} <- Yaml.read_from_file("lib/regimens.yml") do
      %{
        "activities" => Enum.map(yaml["activities"], fn activity -> {activity["id"], activity} end) |> Enum.into(%{}),
        "regimens" => Enum.map(yaml["regimens"], fn regimen -> {regimen["id"], regimen} end) |> Enum.into(%{})
      }
    end
  end

  def list_regimens do
    Niacademy.Db.Cache.get["regimens"]
  end

  def get_regimen(id) do
    case Niacademy.Db.Cache.get["regimens"][id] do
      nil -> raise "Unknown regimen #{id}"
      regimen -> regimen
    end
  end

  def get_activity(id) do
    case Niacademy.Db.Cache.get["activities"][id] do
      nil -> raise "Unknown activity #{id}"
      activity -> activity
    end
  end

  def resolve_activity(id, args) do
    Niacademy.Db.get_activity(id) |> do_resolve_activity(args)
  end

  defp do_resolve_activity(%{"source" => %{"type" => "Custom"}} = activity, args) do
    images = Niacademy.Images.list_for_categories(args[:categories])
    image_file = images |> Enum.random
    extra = %{"imageFiles" => [image_file]}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(%{"source" => %{"type" => "Freeform"}} = activity, _args) do
    activity
  end

  defp do_resolve_activity(%{"source" => %{"type" => "File", "data" => data}} = activity, _args) do
    extra = %{"imageFiles" => data}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(%{"source" => %{"type" => "Categories", "data" => data}} = activity, _args) do
    images = Niacademy.Images.list_for_categories(data["categories"])
    image_files = images |> Enum.take_random(data["imageCount"])
    image_files = data["files"] |> Enum.concat(image_files)
    extra = %{"imageFiles" => image_files}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(activity, _args) do
    raise "Invalid activity #{activity}"
  end

  defp resolve_one(args) do
    with regimen <- Niacademy.Db.list_regimens[args[:regimen_id]],
         categories <- args[:categories] || regimen["defaultCategories"],
         activity_args <- %{categories: categories, regimen: regimen} do
      %{
        regimen_id: args[:regimen_id],
        activities: regimen["activities"] |> Enum.map(& Map.put(&1, :activity, Niacademy.Db.resolve_activity(&1["activityId"], activity_args))),
        categories: categories
      }
    end
  end

  defp arrayize(params) do
    with {count, _} <- Integer.parse(params["count"]) do
      Enum.map(0..count-1, fn i ->
        %{
          regimen_id: params["regimen_id"]["#{i}"],
          categories: case params["categories"]["#{i}"] do
                        nil -> nil
                        x -> Enum.map(x, fn {_, key} -> key end)
                      end
        }
      end)
    end
  end

  def create_session_changeset(params) do
    with data <- arrayize(params),
      resolved <- Enum.map(data, & resolve_one(&1)) do
      %{
        regimen_ids: Enum.map(resolved, & &1[:regimen_id]),
        activities: Jason.encode!(Enum.map(resolved, & &1[:activities]) |> Enum.concat),
        position: 0,
        show_controls: !!params["show_controls"],
        finished: false
      }
    end
  end
end
