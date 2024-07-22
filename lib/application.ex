defmodule KV.Application do
  use Application

  def start(_start_type, _args) do
    # Asegúrate de iniciar el generador de números aleatorios
    :rand.seed(:exsplus, :os.timestamp())

    port_env = System.get_env("PORT")
    port = case port_env do
      nil -> 5000 + :rand.uniform(1001) - 1
      _ -> String.to_integer(port_env)
    end

    # Genera un número aleatorio entre 5000 y 6000
    numero_aleatorio_cluster = 5000 + :rand.uniform(1001) - 1

    IO.puts("Puerto para el server #{port}")
    IO.puts("Número aleatorio para libcluster entre 5000 y 6000: #{numero_aleatorio_cluster}")


    topologies = [
      libcluster_strategy: [
        strategy: Cluster.Strategy.Gossip,
        config:
        [
          hosts: [:"a@127.0.0.1", :"b@127.0.0.1"],
          port: numero_aleatorio_cluster]
        ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: KV.ClusterSupervisor]]}, #libcluster
      {Plug.Cowboy, scheme: :http, plug: KVServer, options: [port: port]},
      #Supervisores
      Datos.Supervisor,
      NodeManager.Supervisor,
      OrquestadorSupervisor,
      NodeObserver.Supervisor,
    ]

    opts = [strategy: :one_for_one, name: KV.SuperSupervisor, max_seconds: 5, max_restarts: 3]

    Supervisor.start_link(children, opts)
  end
end
