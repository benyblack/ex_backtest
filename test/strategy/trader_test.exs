defmodule ExBacktest.Tests.Strategy.Trader do
  use ExUnit.Case
  alias ExBacktest.Strategy.Trader

  test "do_trades should return empty when potential_buy_points is empty" do
    assert Trader.do_trades([],[],[],1,0.1) == {1, %{}}
  end

  @tag :win
  test "do_trades should return history when ponits provided" do
    data = for i <- 100..150, do: i
    {_, new_history} = Trader.do_trades(data, [0,2,3,6,9],[1,5,10],1,0.1)
    assert Map.keys(new_history) == [0,1,2,5,6,10]

  end

  test "buy should return 2 transactions in history when potential_sell_points has one" do
    {_, new_history} = Trader.buy([1, 2, 3], 0, 1, 0.1, [0], [2], %{})
    keys = Map.keys(new_history)
    assert keys == [0, 2]
  end

  test "buy should return 1 transaction in history when potential_sell_points is empty" do
    {_, new_history} = Trader.buy([1, 2, 3], 0, 1, 0.1, [], [], %{})
    assert length(Map.keys(new_history)) == 1
  end

  test "sell should return 1 transaction in history when potential_but_points is empty" do
    {_, new_history} = Trader.sell([1, 2, 3], 1, 0, 1, 0.1, [], [], %{})
    assert length(Map.keys(new_history)) == 1
  end

  test "sell should return 2 transactions in history when potential_sell_points has one" do
    {_, new_history} = Trader.sell([1, 2, 3, 4], 1, 0, 1, 0.1, [2], [1, 3], %{})
    keys = Map.keys(new_history)
    assert keys == [1, 2, 3]
  end

  test "create_transaction should return 1 transaction in history when history is empty" do
    {_, new_history} = Trader.create_transaction("BUY",1, 100, 1, %{})
    keys = Map.keys(new_history)
    assert length(keys) == 1
    assert new_history[hd(keys)]["type"] == "BUY"
  end

  test "create_transaction should merge the new transaction with history when history is NOT empty" do
    history = %{1 => %{"type" => "SELL"}}
    {_, new_history} = Trader.create_transaction("BUY", 2, 100, 1, history)
    keys = Map.keys(new_history)
    assert length(keys) == 2
    assert new_history[1]["type"] == "SELL"
    assert new_history[2]["type"] == "BUY"
  end

end
