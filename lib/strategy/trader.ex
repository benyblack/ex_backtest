defmodule ExBacktest.Strategy.Trader  do
    @buy 'BUY'
    @sell 'SELL'
    @current 'CURRENT'

    @spec do_trades([], [], [], number, number) :: {number, %{}}
    def do_trades(_, [], _, init_cash, _), do: {init_cash, %{}}
    def do_trades(data, potential_buy_points, potential_sell_points, init_cash, commision) do
        new_potential_sell_points = Enum.filter(potential_sell_points, fn(index) -> index > hd(potential_buy_points) end)
        buy(data, hd(potential_buy_points), init_cash, commision, potential_buy_points, new_potential_sell_points, %{})
    end

    @spec buy(list, number, float, float, list, list, map) :: {float, map}
    def buy(data, buy_index, cash, commission, _, [], history) do
        buy_price = Enum.at(data, buy_index)
        {new_cash, new_history} = create_transaction(@buy, buy_index, buy_price, cash, commission, history)
        # Add current cash status if we sell it immediately
        last_data_index = length(data) - 1
        last_data = Enum.at(data, last_data_index)
        last_cash = (last_data / buy_price) * (1 - commission) * new_cash
        create_transaction(@current, buy_index, last_data, last_cash, commission, new_history)
    end
    def buy(data, buy_index, cash, commission, potential_buy_points, potential_sell_points, history) do
        {new_cash, new_history} = create_transaction(@buy, buy_index, Enum.at(data, buy_index), cash, commission, history)
        sell_index = hd(potential_sell_points)
        new_potential_buy_points = Enum.filter(potential_buy_points, fn(index) -> index > sell_index end)
        sell(data, sell_index, buy_index, new_cash, commission, new_potential_buy_points, potential_sell_points, new_history)
    end

    @spec sell(list, number, number, float, float, list, list, map) :: {float, map}
    def sell(data, sell_index, _, cash, commission, [], _, history) do
        sell_price = Enum.at(data, sell_index)
        create_transaction(@sell, sell_index, sell_price, cash, commission, history)
    end
    def sell(data, sell_index, buy_index, cash, commission, potential_buy_points, potential_sell_points, history) do
        {new_cash, new_history} = create_transaction(@sell, sell_index, Enum.at(data, sell_index), cash, commission, history)
        new_buy_index = hd(potential_buy_points)
        new_potential_sell_points = Enum.filter(potential_sell_points, fn(index) -> index > buy_index end)
        buy(data, new_buy_index, new_cash, commission, potential_buy_points, new_potential_sell_points, new_history)
    end

    @spec create_transaction(charlist(), number, float, float, float, map) :: {number, map}
    def create_transaction(type, buy_or_sell_index, price, cash, commission, history) do
        new_cash = cash * (1 - commission)
        new_transaction = %{buy_or_sell_index => %{'type' => type, 'price' => price, 'cash' => new_cash}}
        new_history = Map.merge(history, new_transaction)
        {new_cash, new_history}
    end
end
