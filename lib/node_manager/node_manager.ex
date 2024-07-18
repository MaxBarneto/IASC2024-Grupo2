defmodule NodeManager do
    use GenServer
    require Logger

    @max_capacity 5

    def start_link(_init_arg) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:insert, key, value}, _from_pid, state) do
        agents = Enum.filter(agent_list(), fn x -> DatoAgent.data_size(x) < @max_capacity end)

        if Enum.empty?(get_value(key)) do
            agent_pid = next_agent(agents)
            agent_tuple = DatoRegistry.find_agent_by_pid(agent_pid)
            agent_number = elem(agent_tuple,2)
            replicas = get_replicas_of(agent_number)
            DatoAgent.insert(agent_pid, key,value)
    
            if not Enum.empty?(replicas) do
                Enum.map(replicas, fn replica_pid -> DatoAgent.insert(replica_pid, key,value) end)
            end    
        end

        {:reply, "dato insertado", state}
    end

    def handle_call({:delete, key}, _from_pid, state) do
        Enum.map(agent_list(), fn agent_pid -> DatoAgent.delete(agent_pid, key) end)
        {:reply, "dato borrado", state}
    end

    def handle_call({:get, key}, _from_pid, state) do
        result = get_value(key)
        {:reply, "el valor es: #{result}", state}
    end

    def handle_call({:get_all}, _from_pid, state) do
        dato_List = Enum.map(agent_list(), fn x ->  DatoAgent.getAll(x) end)
        datos = List.foldl(dato_List,%{}, fn x, acc -> Map.merge(acc, x) end)
        {:reply, datos,state}
    end

    def get_value(key) do
        values = Enum.map(agent_list(), fn agent_pid -> DatoAgent.get(agent_pid, key) end)
        Enum.filter(values, fn x -> not is_nil(x) end)
    end

    def agent_list do
        agents = DatoRegistry.find_agents()
        agent_pids = Enum.map(agents, fn {_,x,_} -> x end)
    end

    def next_agent(list) do
        agents = sort_by_most_empty(list)
        List.first(agents)
    end

    def get_replicas_of(value) do
        list = DatoRegistry.find_all
        replicas = DatoRegistry.find_replicas_for(value)
        Enum.map(replicas, fn {_,x,_} -> x end)
    end

    def sort_by_most_empty(list) do
        Enum.sort(list,&(DatoAgent.data_size(&1) <= DatoAgent.data_size(&2)))
    end
end