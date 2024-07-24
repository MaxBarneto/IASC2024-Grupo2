defmodule Kv.MixProject do
  use Mix.Project

  def project do
    [
      app: :kv,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :wx, :observer , :eex, :runtime_tools],
      mod: {KV.Application, []}
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8.3"},
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.3"}
    ]
  end
end
