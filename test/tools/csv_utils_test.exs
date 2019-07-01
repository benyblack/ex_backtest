defmodule ExBacktest.Tests.Tools.CsvUtilsTests do
  use ExUnit.Case
  alias ExBacktest.Tools.CsvUtils

  test "Load file" do
    text =
      "DateTime,Open,High,Low,Close,Volume\n2017-08-17 00:00:00,4261.4800000000,4485.3900000000,4200.7400000000,4285.0800000000,795.1503770000"

    {:ok, device} = text |> StringIO.open()
    stream = device |> IO.binstream(:line)
    [column_names | values] = ExBacktest.Tools.CsvUtils.read_csv(stream)
    assert Enum.count(values) == 1
  end
end
