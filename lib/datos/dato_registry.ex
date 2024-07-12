defmodule DatoRegistry do 
  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.Registry.init()
  end

  defp members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {__MODULE__, node} end)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_state) do
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def init(_state) do
    # Logger.info("DatosRegistry init")
  end

  def find_all_pids() do
    Registry.select(__MODULE__,[{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}]) |> Enum.sort()
  end

  def find(node_name) do
    Horde.Registry.lookup(__MODULE__, node_name)
  end

  def find_all_pids() do
    Horde.Registry.select(__MODULE__,[{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}]) |> Enum.sort()
  end
end
