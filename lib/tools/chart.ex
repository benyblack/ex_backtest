defmodule ExBacktest.Tools.Chart do

  @doc """
  show Send data to a python script and show a chart on the browser

  ##Parameters
    - symbol: Symbol name, for example, "BTCUSDT"
    - data: List of prices
    - dates: List of dates
    - oscillator_data: List of Maps contain oscillator indicators
    - trade_history: Json string of trade history.
  """
  @spec show(String.t(), list(float), String.t(), list(String.t()), list(map), String.t()) :: :ok
  def show(symbol, data, more_data, dates, oscillator_data \\ [%{}], trade_history \\ "{}")

  def show(symbol, data, more_data, dates, oscillator_data, trade_history) do
    path = './priv/'
    {:ok, p} = :python.start([{:python_path, path}])

    :python.call(p, :chart, :make_chart_and_show, [
      symbol,
      data,
      more_data,
      dates,
      oscillator_data,
      trade_history
    ])

    :python.stop(p)
    :ok
  end
end
