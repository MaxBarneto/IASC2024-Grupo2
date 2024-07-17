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

  def find_all_pids() do
    Registry.select(__MODULE__,[{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}]) |> Enum.sort()
  end
end
