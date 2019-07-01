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
end
