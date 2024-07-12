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

  def start_child(initial_state) do
    spec = {DatoAgent, initial_state}
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