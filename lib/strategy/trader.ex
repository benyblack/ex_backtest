defmodule ExBacktest.Strategy.Trader  do
    @buy "BUY"
    @sell "SELL"
    @current "CURRENT"

    @doc """
    do_trades Try to find buy and sell points based on given potential points.
    It starts buy the first buy point and tries to find the nearest sell point.
    It continues to find the next buy points and etc.

    ## Parameters
        - data: An array of price data like Close prices.
        - potential_buy_points: List of indixes which show potential points for buying
        - potential_sell_points: List of indixes which show potential points for selling
        - init_cash: The money to start trading
        - commision: Commision percent, for example, for 1 percent it must be 0.01
    """
    @spec do_trades(list(float), list(integer), list(integer), float, float) :: {number, %{}}
    def do_trades(_, [], _, init_cash, _), do: {init_cash, %{}}
    def do_trades(data, potential_buy_points, potential_sell_points, init_cash, commision) do
        new_potential_sell_points = Enum.filter(potential_sell_points, fn(index) -> index > hd(potential_buy_points) end)
        buy(data, hd(potential_buy_points), init_cash, commision, potential_buy_points, new_potential_sell_points, %{})
    end

    @doc """
    buy Add the current index as a buy point to the history
    ## Parameters
        - data: An array of price data like Close prices.
        - buy_index: Buy index to be added in the history
        - cash: Current amount of the money
        - commision: Commision percent, for example, for 1 percent it must be 0.01
        - potential_buy_points: List of indixes which show potential points for buying
        - potential_sell_points: List of indixes which show potential points for selling
        - history: A map contains trades data. Each item is like this:
                    ```101 => %{"type" => "BUY", "price" => 12.023, "cash" => 1.0023} ```
    """
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

    @doc """
    sell Add the current index as a buy point to the history
    ## Parameters
        - data: An array of price data like Close prices.
        - sell_index: Sell index to be added in the history
        - buy_index: Last buy index
        - cash: Current amount of the money
        - commision: Commision percent, for example, for 1 percent it must be 0.01
        - potential_buy_points: List of indixes which show potential points for buying
        - potential_sell_points: List of indixes which show potential points for selling
        - history: A map contains trades data. Each item is like this:
                    ```101 => %{"type" => "BUY", "price" => 12.023, "cash" => 1.0023} ```
    """
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
        (sell_price/buy_price - commission) * cash
    end

    @doc """
    create_transaction Add a record to the trade hostory
    # Parameters
        type: BUY or SELL or CURRENT. CURRENT is used if the last point is buy and there is no more sell point
        buy_or_sell_index: Trade point index
        price: Value in the index
        cash: Amounnt of current cash
        history: Trade history
    """
    @spec create_transaction(String.t(), number, float, float, map) :: {number, map}
    def create_transaction(type, buy_or_sell_index, price, cash, history) do
        new_transaction = %{buy_or_sell_index => %{"type" => type, "price" => price, "cash" => cash}}
        new_history = Map.merge(history, new_transaction)
        {cash, new_history}
    end
end
