defmodule NodeManager do
  use GenServer
  require Logger

  def start_link(_initial_state) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def node_down(node_id) do
    orquestadores =
    #[{_,_,{type,node}}] = 
      OrquestadorHordeRegistry.get_all |>
      Enum.filter(fn {_,_,{_,node}} -> node != node_id end)

    if orquestadores |> Enum.all?(fn {_,_,{type,node}} -> type != :master end) do
    #if type == :master do
      Logger.info("---- Node master caido ----")
      #OrquestadorHordeRegistry.get_all |>
      #Enum.filter(fn {_,_,{_,node}} -> node == node_id end)
    end
  end
end
