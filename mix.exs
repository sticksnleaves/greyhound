defmodule Greyhound.MixProject do
  use Mix.Project

  def project do
    [
      app: :greyhound,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]
  defp elixirc_paths(_env), do: ["lib", "test"]

  defp package do
    [
      description: "Extensible event bus platform",
      files: ["lib", "config", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/sticksnleaves/greyhound"
      },
      maintainers: ["Anthony Smith"]
    ]
  end
end
