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
      
      #Supervisores
      Datos.Supervisor,
      NodeManager.Supervisor,
      #OrquestadorRegistry,
      OrquestadorHordeRegistry,
      %{id: OrquestadorDynamicSupervisor, start: {OrquestadorDynamicSupervisor, :start_link, [[]]} },
      %{id: NodeObserver, start: {NodeObserver, :start_link, [[]]}},
      %{id: NodeManager, start: {NodeManager, :start_link, [[]]}},
    ]

    opts = [strategy: :one_for_one, name: KV.SuperSupervisor, max_seconds: 5, max_restarts: 3]

    Supervisor.start_link(children, opts)
  end
end