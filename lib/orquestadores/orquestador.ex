defmodule Orquestador do
  use GenServer
  require Logger

  def child_spec({orchestrator_id, type}) do
    %{id: get_process_name(orchestrator_id),
      start: {__MODULE__, :start_link, [orchestrator_id, type]},
      type: :worker,
      restart: :permanent
    }
  end

  def start_link(orchestrator_id, type) do
    name = via_tuple({orchestrator_id, type})
    GenServer.start_link(__MODULE__, {orchestrator_id, type}, name: name)
  end

  def init({orchestrator_id, type}) do
    Logger.info("Orchestrator created, identifier: #{orchestrator_id}")
    #Horde.Registry.register(OrquestadorHordeRegistry, identifier, self())
    {:ok, {orchestrator_id, type}}
  end

  defp via_tuple({orchestrator_id, type}) do
  #{:via, Horde.Registry, {OrquestadorHordeRegistry, orchestrator_id}}
  {:via, Registry, {OrquestadorRegistry, orchestrator_id, type}}
  end

  defp get_process_name(orchestrator_id) do
    String.to_atom("Orq-#{orchestrator_id}")
  end

  def handle_call({:find, key}, _from_pid, state) do
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

  def find(name_or_pid, key) do
    GenServer.call(name_or_pid, {:find, key})
  end

  def insert(name_or_pid, key, value) do
    GenServer.cast(name_or_pid, {:insert, key, value})
  end

  def delete(name_or_pid, key) do
    GenServer.cast(name_or_pid, {:delete, key})
  end
end