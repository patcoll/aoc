defmodule Vents do
  defstruct lines: [], points: []

  @doc """
  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  %Vents{lines: [
    {{0, 0}, {8, 8}},
    {{0, 9}, {2, 9}},
    {{0, 9}, {5, 9}},
    {{2, 2}, {2, 1}},
    {{3, 4}, {1, 4}},
    {{5, 5}, {8, 2}},
    {{6, 4}, {2, 0}},
    {{7, 0}, {7, 4}},
    {{8, 0}, {0, 8}},
    {{9, 4}, {3, 4}},
  ]}

  iex> Vents.create([
  ...>  {{0, 9}, {5, 9}},
  ...>  {{8, 0}, {0, 8}},
  ...>  {{9, 4}, {3, 4}},
  ...>  {{2, 2}, {2, 1}},
  ...>  {{7, 0}, {7, 4}},
  ...>  {{6, 4}, {2, 0}},
  ...>  {{0, 9}, {2, 9}},
  ...>  {{3, 4}, {1, 4}},
  ...>  {{0, 0}, {8, 8}},
  ...>  {{5, 5}, {8, 2}}
  ...>])
  %Vents{lines: [
    {{0, 0}, {8, 8}},
    {{0, 9}, {2, 9}},
    {{0, 9}, {5, 9}},
    {{2, 2}, {2, 1}},
    {{3, 4}, {1, 4}},
    {{5, 5}, {8, 2}},
    {{6, 4}, {2, 0}},
    {{7, 0}, {7, 4}},
    {{8, 0}, {0, 8}},
    {{9, 4}, {3, 4}},
  ]}
  """
  def create(input) when is_binary(input) do
    lines =
      input
      |> Input.parse_vents()
      |> Enum.sort()

    struct(__MODULE__, lines: lines)
  end

  def create(input) when is_list(input) do
    lines =
      input
      |> Enum.sort()

    struct(__MODULE__, lines: lines)
  end

  def merge(%Vents{lines: first_set}, %Vents{lines: second_set}) do
    Vents.create(first_set ++ second_set)
  end

  @doc """
  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  ...> |> Vents.only_horizontal_and_vertical()
  %Vents{lines: [
    {{0, 9}, {2, 9}},
    {{0, 9}, {5, 9}},
    {{2, 2}, {2, 1}},
    {{3, 4}, {1, 4}},
    {{7, 0}, {7, 4}},
    {{9, 4}, {3, 4}},
  ]}
  """
  def only_horizontal_and_vertical(%Vents{} = vents) do
    only_horizontal(vents)
    |> merge(only_vertical(vents))
  end

  def only_horizontal(%Vents{lines: existing_lines}) do
    Vents.create(Enum.filter(existing_lines, &is_horizontal/1))
  end

  def only_vertical(%Vents{lines: existing_lines}) do
    Vents.create(Enum.filter(existing_lines, &is_vertical/1))
  end

  @doc """
  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  ...> |> Vents.only_diagonal()
  %Vents{lines: [
    {{0, 0}, {8, 8}},
    {{5, 5}, {8, 2}},
    {{6, 4}, {2, 0}},
    {{8, 0}, {0, 8}},
  ]}
  """
  def only_diagonal(%Vents{lines: existing_lines}) do
    Vents.create(Enum.filter(existing_lines, &is_diagonal/1))
  end

  @doc """
  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  ...> |> Vents.only_horizontal_vertical_and_diagonal()
  %Vents{lines: [
    {{0, 0}, {8, 8}},
    {{0, 9}, {2, 9}},
    {{0, 9}, {5, 9}},
    {{2, 2}, {2, 1}},
    {{3, 4}, {1, 4}},
    {{5, 5}, {8, 2}},
    {{6, 4}, {2, 0}},
    {{7, 0}, {7, 4}},
    {{8, 0}, {0, 8}},
    {{9, 4}, {3, 4}}
  ]}
  """
  def only_horizontal_vertical_and_diagonal(%Vents{} = vents) do
    only_horizontal(vents)
    |> merge(only_vertical(vents))
    |> merge(only_diagonal(vents))
  end

  def enumerate_points(%Vents{lines: lines}) do
    Enum.map(lines, &enumerate_points/1)
  end

  def enumerate_points({{x, y1}, {x, y2}}) when y1 > y2 do
    enumerate_points({{x, y2}, {x, y1}})
  end

  def enumerate_points({{x, y1}, {x, y2}}) when y1 < y2 do
    Enum.map(y1..y2, & {x, &1})
  end

  def enumerate_points({{x1, y}, {x2, y}}) when x1 > x2 do
    enumerate_points({{x2, y}, {x1, y}})
  end

  def enumerate_points({{x1, y}, {x2, y}}) when x1 < x2 do
    Enum.map(x1..x2, & {&1, y})
  end

  def enumerate_points({{x1, y1}, {x2, y2}}) when abs((y2 - y1) / (x2 - x1)) == 1 do
    x_slope = div(x2 - x1, abs(x2 - x1))
    y_slope = div(y2 - y1, abs(y2 - y1))

    (x1..x2)
    |> Enum.with_index()
    |> Enum.map(fn {_, index} ->
      {x1 + (index * x_slope), y1 + (index * y_slope)}
    end)
  end

  @doc """
  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  ...> |> Vents.only_horizontal_and_vertical()
  ...> |> Vents.count_overlapping_points()
  5

  iex> Vents.create("
  ...> 0,9 -> 5,9
  ...> 8,0 -> 0,8
  ...> 9,4 -> 3,4
  ...> 2,2 -> 2,1
  ...> 7,0 -> 7,4
  ...> 6,4 -> 2,0
  ...> 0,9 -> 2,9
  ...> 3,4 -> 1,4
  ...> 0,0 -> 8,8
  ...> 5,5 -> 8,2
  ...> ")
  ...> |> Vents.only_horizontal_vertical_and_diagonal()
  ...> |> Vents.count_overlapping_points()
  12
  """
  def count_overlapping_points(%Vents{} = vents) do
    vents
    |> Vents.enumerate_points()
    |> List.flatten()
    |> Enum.group_by(&Function.identity/1)
    |> Map.values()
    |> Enum.count(& length(&1) > 1)
  end

  defp is_horizontal({{x, _}, {x, _}}), do: true
  defp is_horizontal(_), do: false

  defp is_vertical({{_, y}, {_, y}}), do: true
  defp is_vertical(_), do: false

  defp is_diagonal({{x1, y1}, {x2, y2}}) when abs((y2 - y1) / (x2 - x1)) == 1 do
    true
  end

  defp is_diagonal(_) do
    false
  end
end
