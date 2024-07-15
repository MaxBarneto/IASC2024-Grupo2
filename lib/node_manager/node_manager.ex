defmodule NodeManager do
    use GenServer

    def start_link(_init_arg) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:insert, key, value}, _from_pid, state) do
        
    end

    def agent_list do
        list = DatoRegistry.find_all
        agents = DatoRegistry.find_agents(list)
        Enum.map(agents, fn {_,x,_} -> x end)
    end

    def get_replicas_of(value) do
        list = DatoRegistry.find_all
        replicas = DatoRegistry.find_replicas_for(list,value)
        Enum.map(replicas, fn {_,x,_} -> x end)
    end







end