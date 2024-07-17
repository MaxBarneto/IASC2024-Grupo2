defmodule OrquestadorHordeRegistry do
	use Horde.Registry

	def start_link(_) do
		Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
	end

	def init(init_arg) do
		[members: members()]
		|> Keyword.merge(init_arg)
		|> Horde.Registry.init()
	end

	def members() do
		[Node.self() | Node.list()]
		|> Enum.map(fn node -> {__MODULE__, node} end)
		#Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
	end

	def get_orchestrator(_identifier) do
		#Horde.Registry.lookup(via_tuple(get_process_name_from_number(identifier)))
		#case Horde.Registry.lookup(via_tuple(get_process_name_from_number(identifier))) do
		  #[{pid, _val}] -> Logger.info("Process ... Account name: #{pid}")
		 # [] -> {:error, :process_not_found}
		#end
	end

  def via_tuple(orchestrator_id, type) do
    {:via, Horde.Registry, {__MODULE__, orchestrator_id, {type, node()}}}
  end

  def via_tuple(orchestrator_id) do
    {:via, Horde.Registry, {__MODULE__, orchestrator_id}}
  end

  def find(orchestrator_id) do
    Horde.Registry.lookup(__MODULE__, orchestrator_id)
  end

  def get_all do
    Horde.Registry.select(__MODULE__, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
  end
end