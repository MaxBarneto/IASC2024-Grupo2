defmodule DatoAgent do
  use Agent
  require Logger
  
  @registry DatoRegistry


  def start(initial_state) do
    Agent.start(fn -> initial_state end, name: __MODULE__)
  end

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
    Registry.register(DatoRegistry, __MODULE__, self())
  end

  def child_spec(initial_state) do
    %{
      id: self(),
      start: {__MODULE__, :start_link, [initial_state]},
      type: :worker,
      restart: :permanent
    }
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
