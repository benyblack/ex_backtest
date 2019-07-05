defmodule ExBacktest.Strategy.SimpleRSI do

  alias TAlib.Indicators.RSI

  @rsi_buy_limit 30
  @rsi_sell_limit 70

  @spec potential_trades(list) :: {list, list}
  def potential_trades(data)do
      rsi_data = RSI.rsi_list(data)
      rsi_indexed_list = Enum.with_index(rsi_data)

      filter_data = fn(list, f) ->
        list
        |> Enum.filter(fn({value, _}) -> f.(value) end)
        |> Enum.map(fn({_, index}) -> index end)
      end

      buy_points = rsi_indexed_list |> filter_data.(fn(val) -> val != nil and val < @rsi_buy_limit end)
      sell_points = rsi_indexed_list |> filter_data.(fn(val) -> val != nil and val > @rsi_sell_limit end)

      {buy_points, sell_points}
  end

end
