defmodule DatoAgent do
  use Agent
  require Logger

  def start(initial_state) do
    Agent.start(fn -> initial_state end, name: __MODULE__)
  end

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def getAll() do
    Agent.get(DatoAgent, fn state -> state end)
  end

  def get(key) do
    Agent.get(DatoAgent, &Map.get(&1, key))
  end

  def insert(key, value) do
    Agent.update(DatoAgent, &Map.put(&1, key, value))
  end

  def delete(key) do
    Agent.update(DatoAgent, &Map.delete(&1, key))
  end
end