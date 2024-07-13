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

	def get_orchestrator(identifier) do
		#Horde.Registry.lookup(via_tuple(get_process_name_from_number(identifier)))
		#case Horde.Registry.lookup(via_tuple(get_process_name_from_number(identifier))) do
		  #[{pid, _val}] -> Logger.info("Process ... Account name: #{pid}")
		 # [] -> {:error, :process_not_found}
		#end
	  end
end