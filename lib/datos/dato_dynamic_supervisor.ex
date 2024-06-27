defmodule DatoDynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end

  def start_child(child_name, state) do
    spec = {Dato, {child_name, state}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

# Examples
# {:ok, pid_1} = DatoDynamicSupervisor.start_child(Nodo1, [])
# Dato.insert(pid_1, :pepe, "pepa")
# Dato.insert(pid_1, :tp, "1C2024")
# Dato.get(pid_1, :pepe)
# Dato.get(pid_1, :tp)
# Dato.delete(pid_1, :tp)
# Dato.get(pid_1, :tp)