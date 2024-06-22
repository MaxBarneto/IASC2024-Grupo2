defmodule Datos.Registry do
  use Horde.Registry
  require Logger

  def start_link(_init) do
      Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end
end