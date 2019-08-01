# ExBacktest

For running the examples:
```
> iex -S mix

ExBacktest.Example.SmaCrossover.run()
```

It will open a browser and will show something like this:

![image](https://user-images.githubusercontent.com/772474/62280598-8c8bd800-b44c-11e9-89da-97f87538c778.png)

Before running the examples you need to have some OHLCV files. There is a repo for Binance data here (https://github.com/benyblack/BinanceDataset/releases/)

For chart I am using Bokeh in python. If you check the python file in priv folder it needs some libraries in Pyhton which have to be installed via PIP.
```
pip install numpy bokeh
```
The docs can be found at [https://hexdocs.pm/ex_backtest](https://hexdocs.pm/ex_backtest).

