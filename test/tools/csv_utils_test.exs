defmodule ExBacktest.Tests.Tools.CsvUtilsTests do
  use ExUnit.Case
  alias ExBacktest.Tools.CsvUtils

  test "Load file" do
    text =
      "DateTime,Open,High,Low,Close,Volume\n2017-08-17 00:00:00,4261.4800000000,4485.3900000000,4200.7400000000,4285.0800000000,795.1503770000"
    {:ok, device} = text |> StringIO.open()
    stream = device |> IO.binstream(:line)
    [_ | values] = CsvUtils.read_csv(stream)
    assert Enum.count(values) == 1
  end

  test "Filter by date range" do
    text =
      "DateTime,Open,High,Low,Close,Volume\n2017-08-17 00:00:00,4261.4800000000,4485.3900000000,4200.7400000000,4285.0800000000,795.1503770000\n2019-03-26 04:00:00,3936.1400000000,3944.6300000000,3936.0100000000,3937.0000000000,627.8153670000"
    {:ok, device} = text |> StringIO.open()
    stream = device |> IO.binstream(:line)
    [_ | filtered_data] = CsvUtils.read_csv(stream) |> CsvUtils.filter_by_date_range("2016-01-01 00:00:00", "2019-01-01 00:00:00")
    assert Enum.count(filtered_data) == 1

    {:ok, device2} = text |> StringIO.open()
    stream2 = device2 |> IO.binstream(:line)
    [_ | filtered_data2] = CsvUtils.read_csv(stream2) |> CsvUtils.filter_by_date_range("2021-01-01 00:00:00", "2019-01-01 00:00:00")
    assert Enum.count(filtered_data2) == 0

  end

  test "Get column's data" do
    data = [["DateTime","Open","Close"],[1,2,3],[4,5,6],[7,8,9]]
    column_data = CsvUtils.get_col(data, "Close")
    assert column_data == [3, 6, 9]
  end

end
