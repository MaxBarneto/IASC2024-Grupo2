defmodule Init do

  def create_orchestrators() do
    case Node.self() do
      :"agent_1@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o1, :master)
      :"agent_2@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o2, :slave)
      :"replica_1@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o3, :slave)
        Orquestador.insert("key1", "value1")
        Orquestador.insert("key2", "value2")
      :"replica_2@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o4, :slave)
        Orquestador.insert("key3", "value3")
        Orquestador.insert("key4", "value4")
      _ -> IO.puts("No se ha encontrado el nodo")
    end
  end
end
