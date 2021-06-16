defmodule Niacademy.Db.Cache do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{data: nil, last_updated: DateTime.utc_now()} end, name: __MODULE__)
  end

  def get do
    with %{data: data, last_updated: last_updated} <- Agent.get(__MODULE__, & &1) do
      case data do
        nil -> Niacademy.Db.Cache.reload
        data ->
          with {:ok, stat} <- File.lstat("config/regimens.yml"),
               {:ok, mtime} <- NaiveDateTime.from_erl(stat.mtime),
                 mtime <- DateTime.from_naive!(mtime, "Etc/UTC") do
            if DateTime.compare(last_updated, mtime) == :lt do
              Niacademy.Db.Cache.reload
            else
              data
            end
          end
      end
    end
  end

  def reload do
    with data <- Niacademy.Db.parse do
      Agent.update(__MODULE__, & %{&1 | data: data, last_updated: DateTime.utc_now()})
      Agent.get(__MODULE__, & Map.get(&1, :data))
    end
  end
end
