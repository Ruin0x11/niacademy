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
    extra = %{"imageFile" => image_file}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(%{"source" => %{"type" => "Freeform"}} = activity, _args) do
    activity
  end

  defp do_resolve_activity(%{"source" => %{"type" => "File", "data" => data}} = activity, _args) do
    extra = %{"imageFile" => data}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(%{"source" => %{"type" => "Categories", "data" => data}} = activity, _args) do
    images = Niacademy.Images.list_for_categories(data)
    image_file = images |> Enum.random
    extra = %{"imageFile" => image_file}

    MapUtils.deep_merge(activity, %{"source" => %{"extra" => extra}})
  end

  defp do_resolve_activity(activity, _args) do
    raise "Invalid activity #{activity}"
  end

  defp create_one_changeset(params) do
    with regimen <- Niacademy.Db.list_regimens[regimen_id],
         categories <- params["categories"] || regimen["defaultCategories"],
         args <- %{categories: categories, regimen: regimen} do
      %{
        regimen_id: regimen_id,
        position: 0,
        activities: Jason.encode!(regimen["activities"] |> Enum.map(& Map.put(&1, :activity, Niacademy.Db.resolve_activity(&1["activityId"], args)))),
        categories: categories
      }
    end
  end
  end

  def create_session_changeset(params) do
end
