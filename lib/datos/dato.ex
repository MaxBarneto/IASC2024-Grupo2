defmodule Dato do
  use GenServer
  require Logger

  @registry Datos.Registry

  def start_link(name, state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(name))
  end 

  def child_spec({name, state}) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name, state]},
      type: :worker,
      restart: :permanent
    }
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {@registry, name}}
  end

  def init(state) do
    {:ok, state}
  end

  ## Handles##

  def handle_call({:get, key}, _from_pid, data) do
    {:reply, DatoAgent.get(key) , data}
  end

  def handle_cast({:insert, key, value}, data) do
    DatoAgent.insert(key, value)
    {:noreply, new_state}
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
