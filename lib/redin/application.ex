defmodule Kv.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: Kv.ClusterSupervisor]]},
      Kv.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Kv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      kv: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "230.1.1.251",
          multicast_ttl: 1
        ]
      ]
    ]
  end
end
