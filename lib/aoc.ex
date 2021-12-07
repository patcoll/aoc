defmodule Aoc do
  @doc """
  Parses the depth report for how quickly the depth increases.

  Returns the number of times the depth has increased in the given report.

  ## Examples

  iex> Aoc.parse_depth_report([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
  7
  iex> Aoc.parse_depth_report([199, 200, 208, 210, 200, 207, 240, 269, 260, 263], 3)
  5
  """
  def parse_depth_report([reading | _] = report, resolution \\ 1) when is_integer(reading) and is_integer(resolution) do
    report
    |> then(fn report ->
      if resolution > 1 do
        report
        |> Enum.chunk_every(resolution, 1, :discard)
        |> Enum.map(&Enum.sum/1)
      else
        report
      end
    end)
    |> parse_depth_report_for_two_items()
  end

  @doc """
  Parses the depth report for how quickly the depth increases.

  Returns the number of times the depth has increased in the given report.
  """
  def parse_depth_report_for_two_items(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&evaluate_depth_report_for_two_items/1)
    |> Enum.filter(&Function.identity/1)
    |> Enum.count()
  end

  @doc """
  Tells you whether the reported depth for the current item index is greater
  than the last in the given report.
  """
  def evaluate_depth_report_for_two_items([first, second | _]) do
    second > first
  end

  def evaluate_depth_report_for_two_items(_), do: false
end
