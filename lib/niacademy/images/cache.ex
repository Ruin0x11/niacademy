defmodule Niacademy.Images.Cache do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{data: nil} end, name: __MODULE__)
  end

  def get do
    with %{data: data} <- Agent.get(__MODULE__, & &1) do
      case data do
        nil -> Niacademy.Images.scan
        data -> data
      end
    end
  end

  def reload do
    with data <- Niacademy.Images.scan do
      Agent.update(__MODULE__, & %{&1 | data: data})
      Agent.get(__MODULE__, & Map.get(&1, :data))
    end
  end
end
