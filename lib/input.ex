defmodule Input do
  @doc """
  iex> Input.parse_elves("
  ...> 1000
  ...> 2000
  ...> 3000
  ...>
  ...> 4000
  ...>
  ...> 5000
  ...> 6000
  ...>
  ...> 7000
  ...> 8000
  ...> 9000
  ...>
  ...> 10000
  ...> ")
  [
		[1000, 2000, 3000],
		[4000],
		[5000, 6000],
		[7000, 8000, 9000],
		[10000]
  ]
  """
  def parse_elves(input) when is_binary(input) do
    input
    |> String.trim()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      line
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&parse_integer/1)
    end)
  end

  @doc """
  iex> Input.parse_fish("3,4,3,1,2")
  [3, 4, 3, 1, 2]
  """
  def parse_fish(input) when is_binary(input) do
    input
    |> parse_delimited_input()
    |> Enum.map(&parse_integer/1)
  end

  @doc """
  iex> Input.parse_vents("
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
  [
    {{0, 9}, {5, 9}},
    {{8, 0}, {0, 8}},
    {{9, 4}, {3, 4}},
    {{2, 2}, {2, 1}},
    {{7, 0}, {7, 4}},
    {{6, 4}, {2, 0}},
    {{0, 9}, {2, 9}},
    {{3, 4}, {1, 4}},
    {{0, 0}, {8, 8}},
    {{5, 5}, {8, 2}}
  ]
  """
  def parse_vents(input) when is_binary(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ", trim: true)
      |> Enum.map(&parse_delimited_input/1)
      |> Enum.map(fn coord ->
        coord
        |> Enum.map(&parse_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end

  @doc """
  iex> Input.parse_bingo("
  ...> 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
  ...>
  ...> 22 13 17 11  0
  ...>  8  2 23  4 24
  ...> 21  9 14 16  7
  ...>  6 10  3 18  5
  ...>  1 12 20 15 19
  ...>
  ...>  3 15  0  2 22
  ...>  9 18 13 17  5
  ...> 19  8  7 25 23
  ...> 20 11 10 24  4
  ...> 14 21 16 12  6
  ...>
  ...> 14 21 17 24  4
  ...> 10 16 15  9 19
  ...> 18  8 23 26 20
  ...> 22 11 13  6  5
  ...>  2  0 12  3  7
  ...> ")
  %{
    numbers: [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21, 24, 10, 16, 13, 6, 15, 25, 12, 22, 18, 20, 8, 19, 3, 26, 1],
    boards: [
      [[22, 13, 17, 11, 0], [8, 2, 23, 4, 24], [21, 9, 14, 16, 7], [6, 10, 3, 18, 5], [1, 12, 20, 15, 19]],
      [[3, 15, 0, 2, 22], [9, 18, 13, 17, 5], [19, 8, 7, 25, 23], [20, 11, 10, 24, 4], [14, 21, 16, 12, 6]],
      [[14, 21, 17, 24, 4], [10, 16, 15, 9, 19], [18, 8, 23, 26, 20], [22, 11, 13, 6, 5], [2, 0, 12, 3, 7]]
    ]
  }
  """
  def parse_bingo(input) when is_binary(input) do
    sections =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.trim/1)

    [numbers | boards] = sections

    numbers =
      numbers
      |> parse_delimited_input()
      |> Enum.map(&parse_integer/1)

    boards =
      boards
      |> Enum.map(fn board_input ->
        board_input
        |> parse_delimited_input()
        |> Enum.map(&parse_delimited_input/1)
        |> Enum.map(fn elements -> Enum.map(elements, &parse_integer/1) end)
      end)

    %{numbers: numbers, boards: boards}
  end

  @doc """
  iex> Input.parse_delimited_input("forward 5, up 3, down 2")
  ["forward 5", "up 3", "down 2"]

  iex> Input.parse_delimited_input("
  ...>  forward 5
  ...>  up 3
  ...>  down 2
  ...> ")
  ["forward 5", "up 3", "down 2"]
  """
  def parse_delimited_input(course) when is_binary(course) do
    course
    |> String.trim()
    |> then(fn course_str ->
      delimiter =
        cond do
          String.contains?(course_str, ",") ->
            ","

          String.contains?(course_str, "\n") ->
            "\n"

          String.contains?(course_str, " ") ->
            " "

          true ->
            ""
        end

      String.split(course_str, delimiter, trim: true)
    end)
    |> Enum.map(&String.trim/1)
  end

  @doc """
  iex> Input.parse_integer("5, up 3, down 2")
  5

  iex> Input.parse_integer("6.0")
  6

  iex> Input.parse_integer("false")
  0
  """
  def parse_integer(amount_str, base \\ 10) when is_binary(amount_str) do
    case Integer.parse(amount_str, base) do
      {amount_int, _} ->
        amount_int

      _ ->
        0
    end
  end

  def parse_binary(amount_str) when is_binary(amount_str) do
    parse_integer(amount_str, 2)
  end
end
