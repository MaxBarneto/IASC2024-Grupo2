defmodule OrquestadorHordeDynamicSupervisor do
  use Horde.DynamicSupervisor

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  def start_child(orchestrator_id, type) do
    spec = {Orquestador, {orchestrator_id, type}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  defp members do
    Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
  end
end

# Examples
# OrquestadorHordeDynamicSupervisor.start_child(:o1, :master)
# OrquestadorHordeDynamicSupervisor.start_child(:o2, :slave)
