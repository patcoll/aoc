defmodule Aoc do
  @doc """
  Parses the depth report for how quickly the depth increases.

  Returns the number of times the depth has increased in the given report.

  ## Examples

  iex> Aoc.parse_depth_report_for_two_items([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
  7
  """
  def parse_depth_report_for_two_items([reading | _] = report) when is_integer(reading) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> IO.inspect(label: "chunks of two")
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

  @doc """
  iex> Aoc.parse_depth_report_for_window_of_three_items([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
  5
  """
  def parse_depth_report_for_window_of_three_items([reading | _] = report) when is_integer(reading) do
    report
    |> Enum.chunk_every(3, 1, :discard)
    |> IO.inspect(label: "chunks of three")
    |> Enum.map(&Enum.sum/1)
    |> IO.inspect(label: "sums")
    |> Enum.chunk_every(2, 1, :discard)
    |> IO.inspect(label: "chunks of two")
    |> Enum.map(&evaluate_depth_report_for_two_items/1)
    |> IO.inspect(label: "evaluate_depth_report_for_two_items")
    |> Enum.filter(&Function.identity/1)
    |> Enum.count()
  end
end
