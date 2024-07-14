defmodule DatoAgent do
  use Agent
  require Logger
  
  @registry DatoRegistry

  def start_link(initial_state, name, value) do
    {:ok, pid} = Agent.start_link(fn -> initial_state end, 
                                  name: {:via, Registry, {DatoRegistry, name, value}})
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def child_spec({state, name}) do
    %{id: name, start: {__MODULE__, :start_link, [state, name]}, type: :worker, restart: :permanent}
  end

  def getAll(pid) do
    Agent.get(pid, fn state -> state end)
  end

  def get(pid, key) do
    Agent.get(pid, fn(state) -> Map.get(state, key) end)
  end

  def insert(pid, key, value) do
    Agent.update(pid, fn(state) -> Map.put(state, key, value) end)
  end

  def delete(pid, key) do
    Agent.update(pid, fn(state) -> Map.delete(state, key) end)
  end
end
