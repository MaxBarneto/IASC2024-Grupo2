defmodule KV.Application do
  use Application

  def start(_start_type, _start_targs) do
    # Asegúrate de iniciar el generador de números aleatorios
    :rand.seed(:exsplus, :os.timestamp())

    node_name = Node.self() |> Atom.to_string() |> String.split("@") |> List.first()
    IO.puts("Inicializando nodo: #{node_name}")

    port_server = Application.get_env(:kv, String.to_atom(node_name), 5000 + :rand.uniform(1001) - 1)

    size_max_key = Application.fetch_env!(:kv, :size_max_key)
    size_max_value = Application.fetch_env!(:kv, :size_max_value)
    max_capacity_for_node = Application.fetch_env!(:kv, :max_capacity_for_node)
    IO.puts("Tamaño maximo para las claves: #{size_max_key}")
    IO.puts("Tamaño maximo para los valores: #{size_max_value}")
    IO.puts("Maxima capacidad de claves para los nodos: #{max_capacity_for_node}")
    IO.puts("Puerto para el server del nodo #{node_name}: #{port_server}")

    topologies = [
      libcluster_strategy: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          hosts: [:"agent_1@127.0.0.1", :"replica_1@127.0.0.1",:"agent_2@127.0.0.1", :"replica_2@127.0.0.1"]
          #port: numero_aleatorio_cluster]
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: KV.ClusterSupervisor]]}, #libcluster
      {Plug.Cowboy, scheme: :http, plug: KVServer, options: [port: port_server]},
      #Supervisores
      Datos.Supervisor,
      NodeManager.Supervisor,
      OrquestadorSupervisor,
      NodeObserver.Supervisor,
    ]

    opts = [strategy: :one_for_one, name: KV.SuperSupervisor, max_seconds: 5, max_restarts: 5]

    Supervisor.start_link(children, opts)
  end
end
