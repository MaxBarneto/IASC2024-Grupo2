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
    #intial_state = Dato.Agent.fecth_status(name)
    {:ok, intial_state}
  end

  def child_spec({name, state}) do
    %{id: name, start: {__MODULE__, :start_link, [state, name]}, type: :worker, restart: :permanent}
  end

  def handle_call(:get, pid, key) do
    dato = DatoAgent.get(key)
    {:reply, dato}
  end

  def handle_call(:insert, {key, value}, state) do
    #DatoAgent.push(key, value)
    {:noreply, state}
  end

  def handle_cast(:delete, pid, key) do
    DatoAgent.pop(key)
    {:noreply}
  end

  def get(name_or_pid, key) do
    GenServer.call(name_or_pid, key, :get)
  end

  def insert(name_or_pid, key, value) do
    GenServer.call(name_or_pid, {key, value}, :insert)
  end

  def delete(name_or_pid, key) do
    GenServer.cast(name_or_pid, {:delete, key})
  end
end

# {:ok, pid_1} = Dato.DynamicSupervisor.start_child(Nodo1, [])
# Dato.insert(pid_1, :pepe, "pepa")