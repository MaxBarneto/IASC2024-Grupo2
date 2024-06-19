defmodule KV.Application do
  use Application

  def start(_start_type, _start_args) do
    IO.puts("Arranca")

    children = []
    opts = [strategy:, :one_for_one]

    Supervisor.start_link(children,opts)
  end

  defp topologies do
    [
      horde_minimal_example: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

end
