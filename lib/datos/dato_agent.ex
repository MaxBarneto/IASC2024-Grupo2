defmodule DatoAgent do
  use Agent
  require Logger
  
  @registry DatoRegistry


  def start_link(initial_state, name, value) do
    {:ok, pid} = Agent.start_link(fn -> initial_state end, name: {:via, Registry, {DatoRegistry, name, value}})
    DatoAgent.init(pid)
  end

  def init(pid) do
    replicated_data = DatoAgent.get_data_from_replicas(pid)
    if not is_nil(replicated_data) do
      Agent.update(pid,fn (state) -> Map.merge(state,replicated_data) end) 
    end
    {:ok, pid}
  end

  def child_spec({state, name, value}) do
    %{id: name, start: {__MODULE__, :start_link, [state, name, value]}, type: :worker, restart: :permanent}
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
    value = DatoRegistry.find_agent_by_pid(pid) |> elem(2)
    replicas = DatoRegistry.find_replicas_for(value)
    replicas_pids = Enum.map(replicas, fn {_,x,_} -> x end)

    if not Enum.empty?(replicas) do
      Enum.map(replicas_pids, fn replica -> Agent.update(replica,fn(state) -> Map.delete(state, key) end) end)
    end
  end

  def data_size(pid) do
    data = DatoAgent.getAll(pid)
    map_size(data)
  end

  def get_data_from_replicas(pid) do
    value = DatoRegistry.find_agent_by_pid(pid) |> elem(2)
    replicas = DatoRegistry.find_replicas_for(value)
    replicas_pids = Enum.map(replicas, fn {_,x,_} -> x end)
    replica_data = Enum.map(replicas_pids, fn pid -> DatoAgent.getAll(pid) end)
    Enum.filter(replica_data, fn map -> map_size(map) > 0 end) |> List.first()
  end

end
