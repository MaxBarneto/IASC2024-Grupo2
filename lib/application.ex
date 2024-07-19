defmodule KV.Application do
  use Application

  def start(_start_type, _start_args) do
    # Asegúrate de iniciar el generador de números aleatorios
    :rand.seed(:exsplus, :os.timestamp())

    # Genera un número aleatorio entre 5000 y 6000
    numero_aleatorio = 5000 + :rand.uniform(1001) - 1
    numero_aleatorio_cluster = 5000 + :rand.uniform(1001) - 1

    IO.puts("Número aleatorio para Plug.Cowboy entre 5000 y 6000: #{numero_aleatorio}")
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
      {Plug.Cowboy, scheme: :http, plug: KVServer, options: [port: numero_aleatorio]},
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
