defmodule OrquestadorDynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
   DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
   DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end

  def start_child(orchestrator_id) do
   spec = {Orquestador, orchestrator_id}
   DynamicSupervisor.start_child(__MODULE__, spec)
  end


  # use Horde.DynamicSupervisor

  # def start_link(init_arg) do
  #   Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  # end

  # def init(init_arg) do
  #   [members: members()]
  #   |> Keyword.merge(init_arg)
  #   |> Horde.DynamicSupervisor.init()
  # end

  # def start_child(child_name) do
  #   spec = {Orquestador, child_name}
  #   Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  # end

  # defp members do
  #   Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
  # end
end

# Examples
# OrquestadorDynamicSupervisor.start_child(:uno)
