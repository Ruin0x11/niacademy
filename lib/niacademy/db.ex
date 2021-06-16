defmodule Niacademy.Db do
  alias YamlElixir, as: Yaml
  require Ecto.Query

  defp mapify(list_with_ids) do
    Enum.map(list_with_ids, fn t -> {t["id"], t} end) |> Enum.into(%{})
  end

  def parse do
    with {:ok, yaml} <- Yaml.read_from_file("config/regimens.yml") do
      %{
        "activities" => mapify(yaml["activities"]),
        "regimens" => mapify(yaml["regimens"]),
        "presets" => mapify(yaml["presets"]),
        "presetOrder" => yaml["presetOrder"]
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

  def list_presets do
    Niacademy.Db.Cache.get["presets"]
  end

  def get_preset_order do
    Niacademy.Db.Cache.get["presetOrder"]
  end

  defp resolve_one(args) do
    with regimen <- Niacademy.Db.list_regimens[args[:regimen_id]],
         categories <- args[:categories] || regimen["defaultCategories"],
         activity_args <- %{categories: categories, regimen: regimen} do
      %{
        regimen_id: args[:regimen_id],
        activities: regimen["activities"] |> Enum.map(& Map.put(&1, :activity, Niacademy.Activity.resolve(&1["activityId"], activity_args))),
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

  defp do_create_changeset(data, show_controls) do
    with resolved <- Enum.map(data, & resolve_one(&1)) do
      %{
        regimen_ids: Enum.map(resolved, & &1[:regimen_id]),
        activities: Jason.encode!(Enum.map(resolved, & &1[:activities]) |> Enum.concat),
        position: 0,
        show_controls: show_controls,
        finished: false
      }
    end
  end

  def create_session_changeset(params) do
    arrayize(params) |> do_create_changeset(!!params["show_controls"])
  end

  def create_session_changeset_from_preset(preset_id) do
    with preset <- Niacademy.Db.list_presets[preset_id] do
      Enum.map(preset["regimens"], fn t ->
        regimen_id = t["regimenId"]
        regimen = Niacademy.Db.list_regimens[regimen_id]
        categories = t["categories"] || regimen["defaultCategories"]

        %{ regimen_id: regimen_id, categories: categories }
      end)
      |> do_create_changeset(false)
      |> Map.put(:tracking_preset, true)
    end
  end

  def get_global_user do
    with username <- Application.get_env(:niacademy, :global_user),
         user <- Niacademy.User |> Ecto.Query.where([u], u.username == ^username) |> Niacademy.Repo.one do
      case user do
        nil -> Niacademy.Repo.insert!(%Niacademy.User{username: username, preset_position: 0})
        user -> user
      end
    end
  end

  def get_current_preset do
    with user <- Niacademy.Db.get_global_user,
         preset_order <- Niacademy.Db.get_preset_order,
           pos <- rem(user.preset_position, Enum.count(preset_order)) do
      {pos, preset_order |> Enum.at(pos)}
    end
  end

  def set_preset_position(position) do
    with user <- Niacademy.Db.get_global_user,
         preset_order <- Niacademy.Db.get_preset_order do
      Niacademy.User.update(user, %{preset_position: rem(position, Enum.count(preset_order))})
    end
  end

  def increment_preset_position do
    with user <- Niacademy.Db.get_global_user do
      set_preset_position(user.preset_position + 1)
    end
  end
end
