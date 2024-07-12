defmodule OrquestadorDynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end

  def start_child(child_name) do
    spec = {Orquestador, child_name}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
