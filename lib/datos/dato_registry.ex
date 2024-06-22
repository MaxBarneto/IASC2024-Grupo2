defmodule DatoRegistry do # Solo se hizo un copy paste
  use Horde.Registry
  require Logger

  def start_link(_init) do
      Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end
end