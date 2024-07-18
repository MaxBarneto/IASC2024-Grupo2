defmodule Orquestador do
  use GenServer
  require Logger

  @master :master
  @slave :slave

  def child_spec({orchestrator_id, type}) do
    %{id: get_process_name(orchestrator_id),
      start: {__MODULE__, :start_link, [orchestrator_id, type]},
      type: :worker,
      shutdown: 500,
      restart: :permanent
    }
  end

  def start_link(orchestrator_id, type) do
    name = via_tuple(orchestrator_id)
    GenServer.start_link(__MODULE__, {orchestrator_id, type}, name: name)
  end

  def init({orchestrator_id, type}) do
    Process.flag(:trap_exit, true)
    Logger.info("Orchestrator created, identifier: #{orchestrator_id} - type: #{type}")
    {:ok, type}
  end

  def terminate(_reason, _state) do
    Logger.info("Me mori")
    #save_state(state)
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
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    DatoAgent.delete(key)
    {:noreply, state}
  end

  def handle_call({:update_state, type}, _from_pid, _state) do
    {:reply, type, type}
  end

  def handle_call(:state, _from_pid, state) do
    {:reply, state, state}
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

  def whereis(identifier) do
    identifier
    |> via_tuple
    |> GenServer.whereis()
  end

  def set_as_master(identifier) do
    GenServer.call(via_tuple(identifier), {:update_state, @master})
  end

  def whoami(identifier) do
    GenServer.call(via_tuple(identifier), :state)
  end

  def is_master(identifier) do
    GenServer.call(via_tuple(identifier), :state) == @master
  end
end