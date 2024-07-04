defmodule Dato do
  use GenServer
  require Logger

  @registry Datos.Registry

  def start_link(name, data) do
    GenServer.start_link(__MODULE__, data, name: via_tuple(name))
  end 

  def child_spec({name, data}) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name, data]},
      type: :worker,
      restart: :permanent
    }
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {@registry, name}}
  end

  def init(data) do
    {:ok, data}
  end

  ## Handles##

  def handle_call({:get, key}, _from_pid, data) do
    valor = Map.get(data, key)
    {:reply, valor, data}
  end

  def handle_cast({:insert, key, value}, data) do
    new_state = Map.put(data, key, value)
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

  ## Pruebas
  def handle_call(:prop, _from, {name, state}) do
    {:reply}
  end
end
