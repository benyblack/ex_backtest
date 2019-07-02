defmodule ExBacktest.Tools.Chart do
  def show(symbol, data, dates, oscillator_data \\ [%{}], trade_history \\ %{})

  def show(symbol, data, dates, oscillator_data, trade_history) do
    path = './priv/'
    {:ok, p} = :python.start([{:python_path, path}])

    :python.call(p, :chart, :make_chart_and_show, [
      symbol,
      data,
      dates,
      oscillator_data,
      trade_history
    ])

    :python.stop(p)
    :ok
  end
end
