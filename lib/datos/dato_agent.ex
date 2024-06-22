defmodule DatoAgent do
  use Agent
  require Logger

  def start do
    Agent.start(fn -> %{} end)
    end

    def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def init(state) do
    {:ok, state}
  end

  def get(key) do
    Agent.get(DatoAgent, &Map.get(&1, key))
  end

  def push(key, value) do
    Agent.update(DatoAgent, &Map.put(&1, key, value))
  end

  def pop(key) do
    Agent.update(DatoAgent, &Map.delete(&1, key))
  end
end