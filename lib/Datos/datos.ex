defmodule NodoDato do
    use GenServer
    require Logger

    def start_link(nodo_id,datos) do
        GenServer.start_link(__MODULE__,{nodo_id,datos},
            name: via_tuple(nodo_id)
        )
    end

    # child spec
    def child_spec({nodo_id, datos}) do
    %{
      id: "nodo_dato#{nodo_id}",
      start: {__MODULE__, :start_link, [nodo_id, datos]},
      type: :worker,
      restart: :transient
    }
    end

    def init({nodo_id,datos}) do
        {max_almacenable} = datos

        datos_state = %DatoState{
            id: nodo_id,
            max_almacenable: max_almacenable,
            pares: Map.new()
        }

        {:ok,{nodo_id,datos_state}}
    end

  


end