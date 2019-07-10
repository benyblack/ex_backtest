import numpy as np
from bokeh.layouts import column
from bokeh.plotting import figure, show, output_file
from bokeh.models import LinearAxis, Range1d
from bokeh.models.annotations import Title
import json
import collections

def datetime(x):
    return np.array(x, dtype=np.datetime64)


def create_plot(chart_title):
    plot = figure(x_axis_type="datetime", title=chart_title, plot_height=500, width=1000)
    plot.grid.grid_line_alpha = 0.3
    plot.xaxis.axis_label = 'Date'
    plot.yaxis.axis_label = 'Price'
    return plot


def create_plot_oscillator(related_plot):
    plot = figure(x_axis_type="datetime", x_range=related_plot.x_range, plot_height=150, width=1000)
    plot.grid.grid_line_alpha = 0.3
    plot.xaxis.axis_label = 'Date'
    plot.yaxis.axis_label = 'Value'
    return plot


def create_plot_trades(related_plot):
    plot = figure(x_axis_type="datetime", x_range=related_plot.x_range, plot_height=150, width=1000)
    plot.grid.grid_line_alpha = 0.3
    plot.xaxis.axis_label = 'Date'
    plot.yaxis.axis_label = 'Price'
    return plot


def add_line_to_plot(plot, data_title, data_date, data_close, color):
    plot.line(datetime(data_date), data_close, color=color, legend=data_title)
    return plot


def add_line_to_plot_with_yrange(plot, data_title, data_date, data_close, color, y_range_name):
    plot.line(datetime(data_date), data_close, color=color, legend=data_title, y_range_name=y_range_name)
    return plot


def add_up_to_plot(plot, data_title, data_date, data_close, color="green"):
    plot.triangle(x=datetime(data_date), y=data_close, color=color, legend=data_title)
    return plot


def add_down_to_plot(plot, data_title, data_date, data_close, color="red"):
    plot.inverted_triangle(x=datetime(data_date), y=data_close,
                           color=color, legend=data_title)
    return plot


def show_plot(plot, oscillator, trades):
    plot.legend.location = "top_left"
    oscillator.legend.location = "top_left"
    trades.legend.location = "top_left"
    output_file("chart.html", title=plot.title.text)
    show(column(children=[plot, oscillator, trades]))


def create_show_single_plot(chart_title):
    plot = create_plot(chart_title)
    plot.legend.location = "top_left"
    output_file("chart.html", title=plot.title.text)
    show(column(children=[plot]))


def show_single_plot(plot):
    plot.legend.location = "top_left"
    output_file("chart.html", title=plot.title.text)
    show(column(children=[plot]))


def make_chart(pair_name: str, data: [], date_data: [], oscillator_data: [{}], trade_history_json: str):
    trade_history = json.loads(trade_history_json)
    # convert keys to integer since json encoder in Elixir convert keys to string
    trade_history_unsorted = {int(k):v for k,v in trade_history.items()}
    # also it needs to be sorted
    trade_history = {}
    for key in sorted(trade_history_unsorted):
        trade_history[key] = trade_history_unsorted[key]

    # 1. create main chart and add series to it
    plot = create_plot(pair_name)
    line_colors = ['lightgray', 'blue', 'maroon']
    add_line_to_plot(plot, pair_name, date_data, data, line_colors[0])
    
    # 2. Add BUY and SELL points to the main char
    buy_indexes = [x for x in trade_history if trade_history[x]['type'] == 'BUY']
    buy_prices = [data[x] for x in buy_indexes]
    buy_dates = [date_data[x] for x in buy_indexes]

    sell_indexes = [x for x in trade_history if trade_history[x]['type'] == 'SELL']
    sell_prices = [data[x] for x in sell_indexes]
    sell_dates = [date_data[x] for x in sell_indexes]
    add_up_to_plot(plot, "Buys", buy_dates, buy_prices)
    add_down_to_plot(plot, "Sells", sell_dates, sell_prices)

    # 3. Create oscillator and add series to it
    oscillator = create_plot_oscillator(plot)

    def add_to_oscillator(item):
        add_line_to_plot(oscillator, decode_str(item[b'title']), date_data, item[b'data'], line_colors[0])

    list(map(add_to_oscillator, oscillator_data))

    # 4. Add Cach + buy and sell data
    trades = create_plot_trades(plot)
    if len(trade_history) > 0:
        cash_history = [trade_history[x]['cash'] for x in trade_history]
        cash_dates = [date_data[x] for x in trade_history]
        cash_min = min(cash_history)
        cash_max = max(cash_history)
        add_up_to_plot(trades, "Buys", buy_dates, buy_prices)
        add_down_to_plot(trades, "Sells", sell_dates, sell_prices)
        trades.extra_y_ranges = {"cash": Range1d(start=cash_min/1.2, end=cash_max*1.2)}
        trades.add_layout(LinearAxis(y_range_name="cash", axis_label="Cash"), 'right')
        add_line_to_plot_with_yrange(trades, "Cash", cash_dates, cash_history, line_colors[0], 'cash')
    return (plot, oscillator, trades)


def make_chart_and_show(pair_name: str, data: [], date_data: [], oscillator_data: [{}], trade_history: {}):
    pair_name = decode_str(pair_name)
    date_data = decode_str_array(date_data)
    plot, oscillator, trades = make_chart(pair_name, data, date_data, oscillator_data, trade_history)
    show_plot(plot, oscillator, trades)

def decode_str(str):
    return ''.join(chr(i) for i in str)

def decode_str_array(str_arr: []):
    return [decode_str(s) for s in str_arr]