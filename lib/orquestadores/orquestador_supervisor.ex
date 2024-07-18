defmodule OrquestadorSupervisor do
  use Supervisor

  def start_link(_) do
      Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      OrquestadorHordeRegistry,
      OrquestadorDynamicSupervisor
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end