# KV

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kv>.

# Startear agent
{:ok, pid} = Datos.DynamicSupervisor.start_child(estado inicial,nombre,valor de asociacion con la replica) 

ejemplo: {:ok, pid} = Datos.DynamicSupervisor.start_child(Map.new,"agent1",1)

# Obtener el pid del node manager
pid = Process.whereis(NodeManager)

# hacer calls al node manager
GenServer.call(pid del nodemanager, {:comando, valores})

ejemplo:  GenServer.call(pid,{:insert,:a,"a"})

