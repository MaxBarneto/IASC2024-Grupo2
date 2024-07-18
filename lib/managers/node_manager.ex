defmodule NodeManager do
  use GenServer
  require Logger

  def start_link(_initial_state) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def node_down(node_id) do
    orquestadores =
      OrquestadorHordeRegistry.get_all |>
      Enum.filter(fn {_,_,{_,node}} -> node != node_id end)

    if is_master_down(orquestadores) do
      {id, _, {_, node}} = orquestadores |> List.first
      Orquestador.set_as_master(id)
      Logger.info("---- Nuevo nodo master: #{node}, #{id} ----")
    end
  end

  def is_master_down(orquestadores) do
    orquestadores |> Enum.all?(fn {id,_,{_,_}} -> !Orquestador.is_master(id) end)
  end
end
