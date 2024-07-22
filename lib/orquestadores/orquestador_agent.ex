defmodule OrquestadorAgent do
  use Agent
  require Logger

  def start_link(_initial_state) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("stoy vivo")
    {:ok, initial_state}
  end

  def get do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def update(state) do
    Agent.update(__MODULE__, fn _ -> state end)
  end
end