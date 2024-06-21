defmodule Kv.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Horde.Registry, [keys: :unique, name: Kv.Registry]},
      {Horde.DynamicSupervisor, [strategy: :one_for_one, name: Kv.DynamicSupervisor]},
      Kv.KVStore
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
