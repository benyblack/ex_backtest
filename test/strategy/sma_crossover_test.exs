defmodule ExBacktest.Tests.Strategy.SmaCrossover do
  use ExUnit.Case
  alias ExBacktest.Strategy.SmaCrossover

  test "can_buy should return " do
    data = for _ <- 1..100, do: 1
    {buy_points, sell_points} = SmaCrossover.potential_trades(data)
    assert length(buy_points) == 0
    assert length(sell_points) == 0
  end
end
