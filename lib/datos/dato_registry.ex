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

  def start_link(_state) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def init(_state) do
    # Logger.info("DatosRegistry init")
  end

  def find(name) do
    Registry.lookup(__MODULE__, name)
  end


  def find_all() do
    Registry.select(__MODULE__,[{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2",:"$3"}}]}]) |> Enum.sort()
  end

  def find_all_pids() do
    Registry.select(__MODULE__,[{{:_, :"$2", :_}, [], [:"$2"]}]) |> Enum.sort()
  end

  def find_replicas_for(value) do
    replicas = find_replicas()
    Enum.filter(replicas, fn {_,_,y} -> (y == value) end)
  end

  def find_replicas() do
    list = DatoRegistry.find_all
    Enum.filter(list, fn {x, _, _} -> String.contains?(x, "replica") end)
  end

  def find_agents() do
    list = DatoRegistry.find_all
    result = Enum.filter(list, fn {x, _, _} -> String.contains?(x, "agent") end)
  end

  def find_agent_by_pid(pid) do
    list = DatoRegistry.find_all
    result = Enum.filter(list, fn {x,y,z} -> (y == pid) end) |> List.first()
  end

  

  #{"agent:1", pid, "1"}, {"replica:1", pid, "1"}, {"replica:2", pid, "1"}
  #result = Enum.filter(list, fn {x, _, _} -> String.contains?(x, "replica") end)
end
