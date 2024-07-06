defmodule Datos.DynamicSupervisor do
  use Horde.DynamicSupervisor

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    [
      members: members(),
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformQuorumDistribution,
      process_redistribution: :active
    ]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  defp members do
    Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
  end

  def start_child(child_name, data) do
    spec = {Dato, {child_name, data}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

# Examples
# {:ok, pid} = Datos.DynamicSupervisor.start_child(Nodo1, [])
# Dato.insert(pid, :pepe, "pepa")
# Dato.insert(pid, :tp, "1C2024")
# Dato.get(pid, :pepe)
# Dato.get(pid, :tp)
# Dato.delete(pid, :tp)
# Dato.get(pid, :tp)
