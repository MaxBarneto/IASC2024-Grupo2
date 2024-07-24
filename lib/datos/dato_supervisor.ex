defmodule Datos.Supervisor do
  use Supervisor

    def start_link(init) do
        Supervisor.start_link(__MODULE__, init, name: __MODULE__)
      end
    
      def init(_init_arg) do
        children = [
          DatoRegistry,
          Datos.DynamicSupervisor,
          {DatoAgent,{Map.new,name(),value()}}
        ]
        opts = [strategy: :one_for_one]
    
        Supervisor.init(children, opts)
      end


      def name do
        cond do
          String.contains?(to_string(Node.self),"agent") ->
            "agent"
          String.contains?(to_string(Node.self),"replica") ->
            "replica"
          true ->
            "agent"
        end
      end

      def value do
        String.split(to_string(Node.self),["-","_","@"]) |> Enum.at(1)
      end
end
