defmodule DatoAgent do
  use Agent
  require Logger
  
  @registry DatoRegistry


  def start_link(initial_state, name, value) do
    {:ok, pid} = Agent.start_link(fn -> initial_state end, name: {:via, Registry, {DatoRegistry, name, value}})
    DatoAgent.init(pid)
  end

  def init(pid) do
    replicated_data = DatoAgent.get_data_from_replicas()
    if not is_nil(replicated_data) do
      Agent.update(pid,fn (state) -> Map.merge(state,replicated_data) end) 
    end
    {:ok, pid}
  end

  def child_spec({state, name, value}) do
    %{id: name, start: {__MODULE__, :start_link, [state, name, value]}, type: :worker, restart: :permanent}
  end

  def getAll() do
    pid = DatoRegistry.find_all_pids |> List.first
    Agent.get(pid, fn state -> state end)
  end

  def get(key) do
    pid = DatoRegistry.find_all_pids |> List.first
    Agent.get(pid, fn(state) -> Map.get(state, key) end)
  end

  def insert(key, value) do
    pid = DatoRegistry.find_all_pids |> List.first
    Agent.update(pid, fn(state) -> Map.put(state, key, value) end)
  end
  
  def delete(key) do
    pid = DatoRegistry.find_all_pids |> List.first
    Agent.update(pid, fn(state) -> Map.delete(state, key) end)
    value = DatoRegistry.find_agent_by_pid(pid) |> elem(2)
    replicas = Enum.filter([Node.self()|Node.list()], 
                fn node -> String.contains?(to_string(node),value) and 
                String.contains?(to_string(node),"replica") end)
    if not Enum.empty?(replicas) do
      Enum.map(replicas, fn replica -> :erpc.call(replica,DatoAgent,:update,[getAll()]) end)
    end
    
  end

  def update(map) do
    pid = DatoRegistry.find_all_pids |> List.first
    Agent.update(pid, fn(state) -> map end)

  end

  def data_size() do
    pid = DatoRegistry.find_all_pids |> List.first
    data = DatoAgent.getAll(pid)
    map_size(data)
  end

  def get_data_from_replicas() do
      if not Enum.empty?(DatoRegistry.find_agents) do
        value = DatoRegistry.find_agents |> List.first |> elem(2)
        replicas = Enum.filter([Node.self()|Node.list()], 
                    fn node -> String.contains?(to_string(node),value) and 
                    String.contains?(to_string(node),"replica") end)
        replica_data = Enum.map(replicas, fn node -> :erpc.call(node,DatoAgent,:getAll,[])  end)
        Enum.filter(replica_data, fn map -> map_size(map) > 0 end) |> List.first()
      end

  end

end
