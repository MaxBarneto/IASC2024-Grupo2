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
    dato = NodeManager.get_value(key)
    {:reply, dato, state}
  end

  def handle_call({:insert, key, value}, _from_pid, state) do
    result = NodeManager.insert(key, value)
    {:reply, result, state}
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

  def handle_call({:find_by_value, value}, _from_pid, state) do
    datos = NodeManager.get_values_greater_than(value)
    {:reply, datos, state}
  end

  def find(identifier, key) do
    GenServer.call(via_tuple(identifier), {:find, key})
  end

  def find(key) do
    {orq_id, _, _} = OrquestadorHordeRegistry.get_any
    GenServer.call(via_tuple(orq_id), {:find, key})
  end

  # def insert(identifier, key, value) do
  #   case is_master(identifier) do
  #     true -> GenServer.cast(via_tuple(identifier), {:insert, key, value})
  #     false -> {:error, "Solo el orquestador master puede insertar datos"}
  #   end
  # end

  def insert(key, value) do
    {orq_id, pid, _} = OrquestadorHordeRegistry.get_any
    case is_master(orq_id) do
      true -> GenServer.call(via_tuple(orq_id), {:insert, key, value})
      false -> {:error, "Solo el orquestador master puede insertar datos"} # TODO: redirigir al master
    end
  end

  def delete(identifier, key) do
    GenServer.cast(via_tuple(identifier), {:delete, key})
  end

  def find_by_value(value) do
    {orq_id, _, _} = OrquestadorHordeRegistry.get_any
    GenServer.call(via_tuple(orq_id), {:find_by_value, value})
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
