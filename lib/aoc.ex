defmodule Aoc do
  @doc """
  Parses the depth report for how quickly the depth increases.

  Returns the number of times the depth has increased in the given report.

  ## Examples

  iex> Aoc.parse_depth_report([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
  7
  """
  def parse_depth_report([reading | _] = report) when is_integer(reading) do
    report
    |> Enum.with_index()
    |> Enum.map(&parse_depth_report_for_item(report, &1))
    |> Enum.filter(&Function.identity/1)
    |> Enum.count()
  end

  @doc """
  Tells you whether the reported depth for the current item index is greater
  than the last in the given report.
  """
  def parse_depth_report_for_item(report, {element, index}) do
    case index - 1 do
      i when i < 0 ->
        false
      i ->
        element > Enum.at(report, i)
    end
  end
end
