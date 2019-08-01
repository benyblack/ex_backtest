# ExBacktest

For running the examples:
```
> iex -S mix

ExBacktest.Example.SmaCrossover.run()
```

It will open a browser and will show something like this:

![image](https://user-images.githubusercontent.com/772474/62280598-8c8bd800-b44c-11e9-89da-97f87538c778.png)

Before running the examples you need to have some OHLCV files. There is a repo for Binance data here (https://github.com/benyblack/BinanceDataset/releases/)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_backtest` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_backtest, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_backtest](https://hexdocs.pm/ex_backtest).

