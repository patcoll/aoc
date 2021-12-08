defmodule Input do
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
      if String.contains?(course_str, ",") do
        String.split(course_str, ",", trim: true)
      else
        String.split(course_str, "\n", trim: true)
      end
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
