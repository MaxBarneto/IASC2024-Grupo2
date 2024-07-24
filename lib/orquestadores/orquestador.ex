defmodule Orquestador do
  use GenServer
  require Logger

  @master :master
  #@slave :slave

  def child_spec({orchestrator_id, type}) do
    %{id: get_process_name(orchestrator_id),
      start: {__MODULE__, :start_link, [orchestrator_id, type]},
      type: :worker,
      shutdown: 500,
      restart: :permanent
    }
  end

  def start_link(orchestrator_id, type) do
    if type == @master && exists_master() do
      {:error, "Ya existe un orquestador master"}
    else
      name = via_tuple(orchestrator_id)
      GenServer.start_link(__MODULE__, {orchestrator_id, type}, name: name)
    end
  end

  def init({orchestrator_id, type}) do
    Process.flag(:trap_exit, true)
    state = OrquestadorAgent.get
    state = if is_nil(state) do type else state end
    Logger.info("Orchestrator created, identifier: #{orchestrator_id} - type: #{state}")
    OrquestadorAgent.update(state)
    {:ok, state}
  end

  def terminate(_reason, state) do
    OrquestadorAgent.update(state)
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

  def handle_call({:update_state, type}, _from_pid, _state) do
    OrquestadorAgent.update(type)
    {:reply, type, type}
  end

  def handle_call({:insert, key, value}, _from_pid, state) do
    result = NodeManager.insert(key, value)
    {:reply, result, state}
  end

  def handle_call({:find_by_value, value, operation}, _from_pid, state) do
    datos = NodeManager.get_values_greater_than(value, operation)
    {:reply, datos, state}
  end

  def handle_call({:delete, key}, _from_pid, state) do
    result = NodeManager.delete(key)
    {:reply, result, state}
  end
  
  def find(identifier, key) do
    GenServer.call(via_tuple(identifier), {:find, key})
  end

  def find(key) do
    case OrquestadorHordeRegistry.get_any() do
      {orq_id, _, _} -> GenServer.call(via_tuple(orq_id), {:find, key})
      _ -> :server_error
    end
  end

  # def insert(identifier, key, value) do
  #   case is_master(identifier) do
  #     true -> GenServer.cast(via_tuple(identifier), {:insert, key, value})
  #     false -> {:error, "Solo el orquestador master puede insertar datos"}
  #   end
  # end

  def insert(key, value) do
    try do
      validate_insert(key, value)
      case OrquestadorHordeRegistry.get_master() do
        [{orq_id, _, _}] -> GenServer.call(via_tuple(orq_id), {:insert, key, value})
        [] -> :server_error
      end
    rescue
      e in RuntimeError -> {:error, e.message}
    end
  end


  def delete(identifier, key) do
    GenServer.cast(via_tuple(identifier), {:delete, key})
  end

  def find_by_value(value, operation) do
    {orq_id, _, _} = OrquestadorHordeRegistry.get_any
    GenServer.call(via_tuple(orq_id), {:find_by_value, value, operation})
  end
  
  def delete(key) do
    case OrquestadorHordeRegistry.get_any() do
      {orq_id, _, _} -> GenServer.call(via_tuple(orq_id), {:delete, key})
      _ -> :server_error
    end
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

  def exists_master do
    OrquestadorHordeRegistry.get_all
    |> Enum.any?(fn {id, _, _} -> is_master(id) end)
  end

  def stop(identifier) do
    GenServer.stop(via_tuple(identifier), :normal)
  end

  def validate_insert(key, value) do
    IO.puts("Validando el tamaño de clave y valor")
    size_max_key = Application.fetch_env!(:kv, :size_max_key)
    size_max_value = Application.fetch_env!(:kv, :size_max_value)

    validate_size(key, size_max_key)
    validate_size(value, size_max_value)
  end

  def validate_size(param, size) do
    param_size = byte_size(param)
    if param_size > size do
      raise "El parametro #{param} no puede ser mayor a #{size} bytes"
    end
    IO.puts("El tamaño de #{param} es valido")
  end

end
