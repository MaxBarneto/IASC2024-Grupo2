defmodule Kv.KVStore do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_cast({:replicate, key, value}, state) do
    new_state = Map.put(state, key, value)
    {:noreply, new_state}
  end

  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
    Horde.Registry.multi_cast(Kv.Registry, {:replicate, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
end
