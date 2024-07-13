defmodule Orquestador do
  use GenServer
  require Logger

  def start(name) do
    GenServer.start(__MODULE__, name: name)
  end

  def start_link(orchestrator_id) do
    name = via_tuple(orchestrator_id)
    GenServer.start_link(__MODULE__, orchestrator_id, name: name)
  end

  def child_spec(orchestrator_id) do
    %{id: get_process_name(orchestrator_id),
      start: {__MODULE__, :start_link, [orchestrator_id]},
      type: :worker,
      restart: :permanent
    }
  end

  def init(orchestrator_id) do
    Logger.info("Orchestrator created, identifier: #{orchestrator_id}")
    #Horde.Registry.register(OrquestadorHordeRegistry, identifier, self())
    {:ok, orchestrator_id}
  end

  defp via_tuple(orchestrator_id) do
  #{:via, Horde.Registry, {OrquestadorHordeRegistry, orchestrator_id}}
  {:via, Registry, {OrquestadorRegistry, orchestrator_id}}
  end

  defp get_process_name(orchestrator_id) do
    String.to_atom("Orq-#{orchestrator_id}")
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