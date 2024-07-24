defmodule KV.Application do
  use Application

  def start(_start_type, _start_targs) do
    # Asegúrate de iniciar el generador de números aleatorios
    :rand.seed(:exsplus, :os.timestamp())
    IO.puts("_start_targs: #{_start_targs}")

    mix_env = System.get_env("MIX_ENV") || "nodo0"
    IO.puts("MIX_ENV: #{mix_env}")

    config = case System.get_env("MIX_ENV") do
      "nodo0" -> "/config/nodo0.exs"
      "nodo1" -> "/config/nodo1.exs"
      "nodo2" -> "/config/nodo2.exs"
      _ -> "/config/config.exs"
    end
    #port = case key_port do
    #  nil -> 5000 + :rand.uniform(1001) - 1
    #  _ -> Application.fetch_env!(:"#{key_port}", :port)
    #end

    # Genera un número aleatorio entre 5000 y 6000
    numero_aleatorio_cluster = 5000 + :rand.uniform(1001) - 1

    #IO.puts("Puerto para el server #{port}")
    IO.puts("Número aleatorio para libcluster entre 5000 y 6000: #{numero_aleatorio_cluster}")

     # Definir el archivo de configuración según el entorno
     #file = Path.join(["#{__DIR__}", config])
    file = Path.expand(config, __DIR__)

    IO.puts("Loading configuration from #{file}")

    if File.exists?(file) do
      Config.Reader.read!(file)
    else
      IO.warn("Configuration file #{file} does not exist")
    end

    value = Application.fetch_env!(:kv, :port)
    IO.puts("Puerto para #{mix_env} port: #{value}")


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
      {Plug.Cowboy, scheme: :http, plug: KVServer, options: [port: 4000]},
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
