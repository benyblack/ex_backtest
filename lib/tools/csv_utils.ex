defmodule ExBacktest.Tools.CsvUtils do
  @moduledoc """
  Functions for reading and parsing trading csv file
  it assumed that they have a format like this:
  ```
    DateTime,Open,High,Low,Close,Volume
    2017-08-17 00:00:00,4261.4800000000,4485.3900000000,4200.7400000000,4285.0800000000,795.1503770000
  ```
  """

  @doc """
  Read CSV
    Read and parse csv file. It returns an array of csv lines.
    each line is an array of values. Head array is names of columns

  ## Parameters
    - Stream: A stream of CSV file or text

  ## Example
  ```
  text = "DateTime,Open,High,..."
    {:ok, device} = text |> StringIO.open()
    stream = device |> IO.binstream(:line)
    [column_names | values] = ExBacktest.Tools.CsvUtils.read_csv(stream)
  ```
  """
  def read_csv(stream) do
    stream
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn
      ["DateTime" | tl] ->
        ["DateTime" | tl]

      [datetime | tl] ->
        inspect(datetime)
        {:ok, ex_datetime} = NaiveDateTime.from_iso8601(datetime)
        [ex_datetime | tl]
    end)
    |> Enum.to_list()
  end

  @doc """
  Filter by date range
    Get csv content and filter it based on a date range

  ## Parameters
    - [h|t]: CSV data with header
    - date_from: date in string, the format must be "%y-%m-%d %H:%M:00" to be parsed with NaiveDateTime.from_iso8601(str_date)

  ## Example
  ```
    [header | filtered_data] = CsvUtils.read_csv(stream) |> CsvUtils.filter_by_date_range("2016-01-01 00:00:00", "2019-01-01 00:00:00")
  ```
  """
  def filter_by_date_range([h | t], date_from, date_until) do
    {:ok, n_date_from} = NaiveDateTime.from_iso8601(date_from)
    {:ok, n_date_until} = NaiveDateTime.from_iso8601(date_until)
    datetime_col_index = Enum.find_index(h, fn x -> x == "DateTime" end)
    filtered_data = Enum.filter(t, fn x ->
      NaiveDateTime.compare(Enum.at(x, datetime_col_index), n_date_from) == :gt and
      NaiveDateTime.compare(Enum.at(x, datetime_col_index), n_date_until) == :lt
    end)
    [h | filtered_data]
  end

  @doc """
  Get column's data
    Return an array of values belong to a column in the csv data
  
  ## Parameters
    - [h|t]: CSV data with header
    - col_name: Name of the column
  
  ## Example
  ```
    data = [["DateTime","Open","Close"],[1,2,3],[4,5,6],[7,8,9]]
    column_data = CsvUtils.get_col(data, "Close")
    # column_data == [3,6,9]
  ```
  """
  def get_col([h | t], col_name) do
    col_index = Enum.find_index(h, fn x -> x == col_name end)
    inspect(hd(t))
    Enum.map(t, fn x -> Enum.at(x, col_index) end)
  end

end
