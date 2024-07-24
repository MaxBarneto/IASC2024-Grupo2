defmodule Init do

  def create_orchestrators() do
    case Node.self() do
      :"agent_1@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o1, :master)
      :"agent_2@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o2, :slave)
      :"replica_1@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o3, :slave)
      :"replica_2@127.0.0.1" ->
        OrquestadorDynamicSupervisor.start_child(:o4, :slave)
      _ ->
        :ok
    end
  end
end
