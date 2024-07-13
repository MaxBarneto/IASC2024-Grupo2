defmodule OrquestadorRegistry do
  require Logger

	def child_spec(init_arg) do
		%{
		  id: __MODULE__,
		  start: {__MODULE__, :start_link, [init_arg]},
		  type: :worker,
		  restart: :permanent
		}
	end

	def start_link(_init_arg) do
		Registry.start_link(keys: :unique, name: __MODULE__)
	end

  def register_orchestrator(identifier, pid) do
    Registry.register(__MODULE__, identifier, pid)
  end

  def get_orchestrator(identifier) do
    Registry.lookup(__MODULE__, identifier)
  end
end