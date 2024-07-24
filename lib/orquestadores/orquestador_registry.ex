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

  def via_tuple(orchestrator_id, type) do
    {:via, Registry, {__MODULE__, orchestrator_id, type}}
  end

  def via_tuple(orchestrator_id) do
    {:via, Registry, {__MODULE__, orchestrator_id}}
  end

  def get_all do
    Registry.select(__MODULE__,[{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]) |> Enum.sort()
  end
end