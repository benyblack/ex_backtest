defmodule ExBacktest.Example.SmaCrossover do

  alias ExBacktest.Strategy.Trader
  alias ExBacktest.Strategy.SmaCrossover
  alias ExBacktest.Tools.CsvUtils
  alias ExBacktest.Tools.Chart
  alias TAlib.Indicators.MA
  alias Jason

  @symbol "BTCUSDT"
  @time_frame "1d"
  @cash 1.0
  @commission 0.01

  def run() do
    file_path = '../binance_data/data/#{@symbol}/#{@time_frame}-#{@symbol}.csv'
    {:ok, file} = File.open(file_path)
    stream  =IO.binstream(file, :line)
    data = CsvUtils.read_csv(stream)
    dates = CsvUtils.get_col(data, "DateTime")
    close = data  |> CsvUtils.get_col("Close")
                  |> Enum.map(fn(x) ->
                    {num, _} = Float.parse(x)
                    num
                  end)

    {buys, sells } = SmaCrossover.potential_trades(close)
    rsi_data = TAlib.Indicators.RSI.rsi_list(close) |> Enum.map(fn
      nil -> 0
      xx ->
        x = to_string(xx)
      {num,_} = Float.parse(x)
      num
    end)
    rsi_oscilator_data = %{"title"=> "RSI 14", "data" => rsi_data}

    sma_10 = MA.sma_list(close, 10)
    sma_20 = MA.sma_list(close, 20)

    more_data = %{"SMA 10" => sma_10, "SMA20" => sma_20}
    more_data_str = Jason.encode!(more_data)

    {final_cash, history} = Trader.do_trades(close, buys, sells, @cash, @commission)
    history_json = Jason.encode!(history)
    IO.puts(final_cash)
    Chart.show(@symbol, close, more_data_str, dates,[rsi_oscilator_data],history_json)
    :ok
  end
end
