defmodule KV.Application do
  use Application

  def start(_start_type, _start_args) do
    topologies = [
      libcluster_strategy: [
        strategy: Cluster.Strategy.Gossip,
        config: [hosts: [:"a@127.0.0.1", :"b@127.0.0.1"]]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: KV.ClusterSupervisor]]}, #libcluster
      {Plug.Cowboy, scheme: :http, plug: KVServer, options: [port: 3000]}
      #Supervisores
      Datos.Supervisor,
      NodeManager.Supervisor,
      %{id: OrquestadorDynamicSupervisor, start: {OrquestadorDynamicSupervisor, :start_link, [[]]} },
    ]

    opts = [strategy: :one_for_one, name: KV.SuperSupervisor, max_seconds: 5, max_restarts: 3]

    Supervisor.start_link(children, opts)
  end
end