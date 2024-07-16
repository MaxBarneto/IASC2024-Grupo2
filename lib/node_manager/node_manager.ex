defmodule NodeManager do
    use GenServer

    def start_link(_init_arg) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:insert, key, value}, _from_pid, state) do
        agent_pid = next_agent(agent_list())
        agent_tuple = DatoRegistry.find_agent_by_pid(agent_pid)
        agent_number = elem(agent_tuple,2)
        replicas = get_replicas_of(agent_number)
        DatoAgent.insert(agent_pid, key,value)

        if not Enum.empty?(replicas) do
            Enum.map(replicas, fn replica_pid -> DatoAgent.insert(replica_pid, key,value) end)
        end
        

        {:reply, "dato insertado en #{elem(agent_tuple, 0)}", state}
    end

    def agent_list do
        agents = DatoRegistry.find_agents()
        Enum.map(agents, fn {_,x,_} -> x end)
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