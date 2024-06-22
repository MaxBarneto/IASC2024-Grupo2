defmodule Dato do
  use GenServer
  require Logger

  def start(intial_state, name) do
    GenServer.start(__MODULE__, intial_state, name: name)
  end

  def start_link(intial_state, name) do
    GenServer.start_link(__MODULE__, intial_state, name: name)
  end

  def init(intial_state) do
    intial_state = DatoAgent.getAll()
    {:ok, intial_state}
  end

  def child_spec({name, state}) do
    %{id: name, start: {__MODULE__, :start_link, [state, name]}, type: :worker, restart: :permanent}
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

# {:ok, pid_1} = Dato.DynamicSupervisor.start_child(Nodo1, [])
# Dato.insert(pid_1, :pepe, "pepa")
# Dato.insert(pid_1, :tp, "1C2024")
# Dato.get(pid_1, :pepe)
# Dato.get(pid_1, :tp)
# Dato.delete(pid_1, :tp)
# Dato.get(pid_1, :tp)
