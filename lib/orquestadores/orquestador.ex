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
    name = via_tuple(orchestrator_id, type)
    GenServer.start_link(__MODULE__, {orchestrator_id, type}, name: name)
  end

  def init({orchestrator_id, type}) do
    Logger.info("Orchestrator created, identifier: #{orchestrator_id} - type: #{type}")
    #Horde.Registry.register(OrquestadorHordeRegistry, identifier, self())
    {:ok, {orchestrator_id, type}}
  end

  defp via_tuple(orchestrator_id, type) do
    #OrquestadorRegistry.via_tuple(orchestrator_id, type)
    OrquestadorHordeRegistry.via_tuple(orchestrator_id, type)
  end

  defp via_tuple(orchestrator_id) do
    #OrquestadorRegistry.via_tuple(orchestrator_id, type)
    OrquestadorHordeRegistry.via_tuple(orchestrator_id)
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

  def handle_call({:fake, message}, _from_pid, state) do
    Logger.info("Recibido: #{message}")
    {:reply, self(), state}
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

  def send_message(identifier, message) do
    GenServer.call(via_tuple(identifier), {:fake, message})
  end

  def whereis(identifier) do
    identifier
    #|> OrquestadorRegistry.via_tuple
    |> OrquestadorHordeRegistry.via_tuple
    |> GenServer.whereis()
  end
end