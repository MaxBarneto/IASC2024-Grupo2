defmodule Datos.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(initial_state, name, value) do
    spec = {DatoAgent, {initial_state, name, value}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

# {:ok, pid1} = Datos.DynamicSupervisor.start_child(Map.new, :agent1, 1)
# Dato.insert(pid_1, :pepe, "pepa")
# Dato.insert(pid_1, :tp, "1C2024")
# Dato.get(pid_1, :pepe)
# Dato.get(pid_1, :tp)
# Dato.delete(pid_1, :tp)
# Dato.get(pid_1, :tp)