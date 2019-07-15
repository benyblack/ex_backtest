defmodule ExBacktest.MixProject do
  use Mix.Project

  @app_name :ex_backtest
  @version "0.0.1"
  @elixir_version "~> 1.8"
  @github "https://github.com/benyblack/ex_backtest"

  def project do
    [
      app: :ex_backtest,
      name: @app_name,
      version: @version,
      elixir: @elixir_version,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def package do
    [
      name: @app_name,
      description: "Backtesting Tools",
      licenses: ["MIT"],
      maintainers: ["Behnam Shomali"],
      links: %{Github: @github}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:erlport, "~> 0.9"},
      {:talib, "~> 0.3.6"},
      {:jason, "~> 1.1"}
    ]
  end
end
