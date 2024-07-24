defmodule OrquestadorHordeRegistry do
	use Horde.Registry
	require Logger

	def start_link(_) do
		Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
	end

	def init(init_arg) do
		[members: members()]
		|> Keyword.merge(init_arg)
		|> Horde.Registry.init()
	end

	defp members() do
		[Node.self() | Node.list()]
		|> Enum.map(fn node -> {__MODULE__, node} end)
		#Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
	end

  def via_tuple(orchestrator_id) do
    {:via, Horde.Registry, {__MODULE__, orchestrator_id, node()}}
  end

  def find(orchestrator_id) do
    Horde.Registry.lookup(__MODULE__, orchestrator_id)
  end

  def get_all do
    Horde.Registry.select(__MODULE__, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
  end

	def get_any do
    case get_all() do
      [] -> nil
      orquestadores -> Enum.random(orquestadores)
    end
  end

  def get_master do
    get_all() |> Enum.filter(fn {id, _, _} -> Orquestador.is_master(id) end)
  end
end