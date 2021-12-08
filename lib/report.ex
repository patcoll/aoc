defmodule Report do
  defstruct elements: []

  def create(report) when is_binary(report) do
    %Report{elements: parse_elements(report)}
  end

  @doc """
  iex> Report.parse_elements("00100, 11110")
  [[0, 0, 1, 0, 0], [1, 1, 1, 1, 0]]
  """
  def parse_elements(report) when is_binary(report) do
    report
    |> Input.parse_delimited_input()
    |> Enum.map(fn el ->
      el
      |> String.split("", trim: true)
      |> Enum.map(&Input.parse_integer/1)
    end)
  end

  @doc """
  iex> Report.create("00100, 11110, 10110, 10111, 10101, 01111, 00111, 11100, 10000, 11001, 00010, 01010")
  ...> |> Report.gamma_rate()
  22
  """
  def gamma_rate(%Report{} = report) do
    find_common_bit_for_each_column(report, :most_common)
  end

  @doc """
  iex> Report.create("00100, 11110, 10110, 10111, 10101, 01111, 00111, 11100, 10000, 11001, 00010, 01010")
  ...> |> Report.epsilon_rate()
  9
  """
  def epsilon_rate(%Report{} = report) do
    find_common_bit_for_each_column(report, :least_common)
  end

  @doc """
  iex> Report.create("00100, 11110, 10110, 10111, 10101, 01111, 00111, 11100, 10000, 11001, 00010, 01010")
  ...> |> Report.oxygen_generator_rating()
  23
  """
  def oxygen_generator_rating(%Report{} = report) do
    reduce_with_common_bit_for_each_column(report, :most_common)
  end

  @doc """
  iex> Report.create("00100, 11110, 10110, 10111, 10101, 01111, 00111, 11100, 10000, 11001, 00010, 01010")
  ...> |> Report.co2_scrubber_rating()
  10
  """
  def co2_scrubber_rating(%Report{} = report) do
    reduce_with_common_bit_for_each_column(report, :least_common)
  end

  defp sort_by_count([{_, _} | _] = values, sort_input) do
    sort =
      %{most_common: :desc, least_common: :asc}
      |> Map.get(sort_input, :desc)

    Enum.sort_by(values, fn {count, _} -> count end, sort)
  end

  defp get_sorted_value([{count, 1}, {count, 0} | _], :most_common), do: 1
  defp get_sorted_value([{count, 0}, {count, 1} | _], :most_common), do: 1
  defp get_sorted_value([{count, 1}, {count, 0} | _], :least_common), do: 0
  defp get_sorted_value([{count, 0}, {count, 1} | _], :least_common), do: 0
  defp get_sorted_value([{_, value} | _], _), do: value

  defp count_common_bit_for_column([bit | _] = column_values) when bit in [0, 1] do
    column_values
    |> Enum.split_with(& &1 == 0)
    |> Tuple.to_list()
    |> Enum.map(&Enum.count/1)
    |> Enum.with_index()
  end

  defp find_common_bit_for_each_column(%Report{} = report, sort_input) do
    report.elements
    |> Enum.zip()
    |> Enum.map(fn column_values ->
      column_values
      |> Tuple.to_list()
      |> count_common_bit_for_column()
      |> sort_by_count(sort_input)
      |> get_sorted_value(sort_input)
    end)
    |> Enum.join()
    |> Input.parse_binary()
  end

  defp reduce_with_common_bit_for_each_column(%Report{elements: [first_element | _]} = report, sort_input) do
    (0..(length(first_element) - 1))
    |> Enum.reduce_while(report.elements, fn index, elements ->
      column_values =
        elements
        |> Enum.zip()
        |> Enum.at(index)
        |> Tuple.to_list()

      least_common_value =
        column_values
        |> count_common_bit_for_column()
        |> sort_by_count(sort_input)
        |> get_sorted_value(sort_input)

      filtered_elements =
        Enum.filter(elements, fn element ->
          Enum.at(element, index) == least_common_value
        end)

      if length(filtered_elements) > 1 do
        {:cont, filtered_elements}
      else
        {:halt, filtered_elements}
      end
    end)
    |> Enum.at(0)
    |> Enum.join()
    |> Input.parse_binary()
  end
end
