defmodule ExBacktest.Strategy.SmaCrossover do

  alias TAlib.Indicators.MA
  @sma_lower_band 10
  @sma_upper_band 20

  @spec prev_sma(list(float), list(float)) :: {float, float}
  def prev_sma(lows, highs) when length(lows) < 2, do: {hd(lows), hd(highs)}
  def prev_sma(lows, highs) do
      prev_lower_sma = hd(tl(lows))
      prev_upper_sma = hd(tl(highs))
      if prev_lower_sma == prev_upper_sma, do: prev_sma(tl(lows), tl(highs))
      {prev_lower_sma, prev_upper_sma}
  end


  @spec add_buy_point(float, float, float, float, list(integer), integer) :: list(integer)
  def add_buy_point(prev_low, prev_high, cur_low, cur_high, buys, index)
               when prev_low < prev_high and cur_low > cur_high, do: buys ++ [index]
  def add_buy_point(_, _, _, _, buys, _), do: buys

  @spec add_sell_point(float, float, float, float, list(integer), integer) :: list(integer)
  def add_sell_point(prev_low, prev_high, cur_low, cur_high, sells, index)
               when prev_low > prev_high and cur_low < cur_high, do: sells ++ [index]
  def add_sell_point(_, _, _, _, sells, _), do: sells

  @spec buys_sells(list(float), list(float), list(integer), list(integer)) :: {any, any}
  def buys_sells(lows, _, buys, sells) when length(lows) < 2, do: {buys, sells}
  def buys_sells(lows, highs, buys, sells) do
    {prev_lower_sma, prev_upper_sma} = prev_sma(lows, highs)
    new_buys = add_buy_point(prev_lower_sma, prev_upper_sma, hd(lows), hd(highs), buys, length(lows)-1)
    new_sells = add_sell_point(prev_lower_sma, prev_upper_sma, hd(lows), hd(highs), sells, length(lows)-1)
    buys_sells(tl(lows), tl(highs), new_buys, new_sells)
  end

  def potential_trades(data) do
      sma_low_list = MA.sma_list(data, @sma_lower_band)
      sma_high_list = MA.sma_list(data, @sma_upper_band)
      reversed_sma_low_list = Enum.reverse(sma_low_list)
      reversed_sma_high_list = Enum.reverse(sma_high_list)
      {reversed_buys, reversed_sells} = buys_sells(reversed_sma_low_list, reversed_sma_high_list, [], [])
      buys = Enum.map(reversed_buys, fn(x) -> length(sma_high_list) - x - 1 end)
      sells = Enum.map(reversed_sells, fn(x) -> length(sma_high_list) - x - 1 end)
      {buys, sells}
  end

end
