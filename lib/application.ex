defmodule KV.Application do
  use Application

  def start(_start_type, _start_args) do
    import Supervisor.Spec, warn: false
    #children = [
     # {Cluster.Supervisor, [topologies(), [name: KV.ClusterSupervisor]]}, #libcluster
      #KV.HordeRegistry, # horde registry
      #{Dato.DynamicSupervisor, [strategy: :one_for_one, distribution_strategy: Horde.UniformQuorumDistribution, process_redistribution: :active]},
      #KV.NodeObserver.Supervisor # custom node supervisor
    #]

    topologies = [
        libcluster_strategy: [
          strategy: Cluster.Strategy.Gossip
        ]
      ]

    children = [
      {Cluster.Supervisor, [topologies, [name: KV.ClusterSupervisor]]}, #libcluster
      %{id: DatoAgent, start: {DatoAgent, :start_link, [%{}]}, restart: :permanent},
      %{id: DatoDynamicSupervisor, start: {DatoDynamicSupervisor, :start_link, [[]]} },
      %{id: OrquestadorDynamicSupervisor, start: {OrquestadorDynamicSupervisor, :start_link, [[]]} }
    ]

    opts = [strategy: :one_for_one, name: KV.SuperSupervisor, max_seconds: 5, max_restarts: 3]

    Supervisor.start_link(children, opts)
  end
end