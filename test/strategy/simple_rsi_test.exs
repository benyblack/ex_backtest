defmodule ExBacktest.Tests.Strategy.SimpleRsi do
  use ExUnit.Case
  alias ExBacktest.Strategy.SimpleRSI

  test "potential_trades should return " do
    data = for _ <- 1..100, do: 1
    {buy_points, sell_points} = SimpleRSI.potential_trades(data)
    assert length(buy_points) == 0
    assert length(sell_points) == 86
  end
end
