defmodule Orquestador do
    use GenServer
    require Logger

    def start(name) do
        GenServer.start(__MODULE__, name: name)
    end

    def start_link(name) do
        GenServer.start_link(__MODULE__, name: name)
    end

    def child_spec(name) do
        %{id: name,
          start: {__MODULE__, :start_link, name},
          type: :worker,
          restart: :permanent
        }
    end

    def init(init_arg) do
        {:ok, init_arg}
      end

    def handle_call({:get, key}, _from_pid, state) do
        dato = DatoAgent.get(key)
        {:reply, dato, state}
    end
    
    def handle_cast({:insert, key, value}, state) do
        DatoAgent.insert(key, value)
        {:noreply, {key, value}}
    end
    
    def handle_cast({:delete, key}, state) do
        DatoAgent.delete(key)
        {:noreply, state}
    end
    
    def get(name_or_pid, key) do
        GenServer.call(name_or_pid, {:get, key})
    end
    
    def insert(name_or_pid, key, value) do
        GenServer.cast(name_or_pid, {:insert, key, value})
    end
    
    def delete(name_or_pid, key) do
        GenServer.cast(name_or_pid, {:delete, key})
    end
end