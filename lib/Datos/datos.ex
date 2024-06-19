defmodule NodoDato do
    use GenServer
    require Logger

    def start_link(nodo_id,tuplas) do
        GenServer.start_link(__MODULE__,{nodo_id,tuplas},
            name: via_tuple(nodo_id)
        )
    end


end