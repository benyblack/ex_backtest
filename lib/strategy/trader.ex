defmodule ExBacktest.Strategy.Trader  do
    @buy "BUY"
    @sell "SELL"
    @current "CURRENT"

    @spec do_trades([], [], [], number, number) :: {number, %{}}
    def do_trades(_, [], _, init_cash, _), do: {init_cash, %{}}
    def do_trades(data, potential_buy_points, potential_sell_points, init_cash, commision) do
        new_potential_sell_points = Enum.filter(potential_sell_points, fn(index) -> index > hd(potential_buy_points) end)
        buy(data, hd(potential_buy_points), init_cash, commision, potential_buy_points, new_potential_sell_points, %{})
    end

    @spec buy(list, number, float, float, list, list, map) :: {float, map}
    def buy(data, buy_index, cash, commission, _, [], history) do
        buy_price = Enum.at(data, buy_index)
        {new_cash, new_history} = create_transaction(@buy, buy_index, buy_price, cash * (1-commission), history)
        # Add current cash status if we sell it immediately
        last_data_index = length(data) - 1
        last_data = Enum.at(data, last_data_index)
        last_cash = calc_trade_resault(buy_price, last_data, commission, new_cash)
        create_transaction(@current, buy_index, last_data, last_cash, new_history)
    end
    def buy(data, buy_index, cash, commission, potential_buy_points, potential_sell_points, history) do
        {new_cash, new_history} = create_transaction(@buy, buy_index, Enum.at(data, buy_index), cash * (1-commission), history)
        sell_index = hd(potential_sell_points)
        new_potential_buy_points = Enum.filter(potential_buy_points, fn(index) -> index > sell_index end)
        sell(data, sell_index, buy_index, new_cash, commission, new_potential_buy_points, potential_sell_points, new_history)
    end

    @spec sell(list, number, number, float, float, list, list, map) :: {float, map}
    def sell(data, sell_index, buy_index, cash, commission, [], _, history) do
        sell_price = Enum.at(data, sell_index)
        buy_price = Enum.at(data, buy_index)
        new_cash = calc_trade_resault(buy_price, sell_price, commission, cash)
        create_transaction(@sell, sell_index, sell_price, new_cash, history)
    end
    def sell(data, sell_index, buy_index, cash, commission, potential_buy_points, potential_sell_points, history) do
        sell_price = Enum.at(data, sell_index)
        buy_price = Enum.at(data, buy_index)
        new_cash = calc_trade_resault(buy_price, sell_price, commission, cash)
        {new_cash, new_history} = create_transaction(@sell, sell_index, Enum.at(data, sell_index), new_cash, history)
        new_buy_index = hd(potential_buy_points)
        new_potential_sell_points = Enum.filter(potential_sell_points, fn(index) -> index > buy_index end)
        buy(data, new_buy_index, new_cash, commission, potential_buy_points, new_potential_sell_points, new_history)
    end

    def calc_trade_resault(buy_price, sell_price, commission, cash) do
        z = (sell_price/buy_price - commission) * cash
        # IO.puts('#{buy_price<sell_price} #{buy_price} #{sell_price} #{cash} #{commission} #{z}')

        # IO.puts(z)
        z
    end

    @spec create_transaction(String.t(), number, float, float, map) :: {number, map}
    def create_transaction(type, buy_or_sell_index, price, cash, history) do
        new_transaction = %{buy_or_sell_index => %{"type" => type, "price" => price, "cash" => cash}}
        new_history = Map.merge(history, new_transaction)
        {cash, new_history}
    end
end
