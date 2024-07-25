defmodule Init do

  def create_orchestrators() do
    nodos = [Node.self() | Node.list]

    nodos |> Enum.each(fn node -> 
      name = for _ <- 1..5, into: "", do: <<Enum.random(to_charlist("abcdef0123456789"))>>
      :erpc.call(node, OrquestadorDynamicSupervisor,:start_child, [name, :slave])
    end)
    
    {orq_id, _, _} = OrquestadorHordeRegistry.get_any
    Orquestador.set_as_master(orq_id)
  end

  def load_data(percentage) do
    capacity = Application.fetch_env!(:kv, :max_capacity_for_node) * length(NodeManager.agent_node_list()) * percentage
    IO.puts("Llenando la DB con #{capacity} datos")

    Enum.each(0..trunc(capacity), fn _ ->
      key = for _ <- 1..3, into: "", do: <<Enum.random(to_charlist("abcde"))>>
      value = for _ <- 1..5, into: "", do: <<Enum.random(to_charlist("abcde"))>>
      Orquestador.insert(key, value)
    end)
  end
end
