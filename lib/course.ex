defmodule Course do
  defstruct origin: %Location{}, steps: []

  def create(course) when is_binary(course) do
    %Course{steps: parse_course(course)}
  end

  @doc """
  iex> Course.create("forward 5, down 5, forward 8, up 3, down 8, forward 2")
  ...> |> Course.navigate()
  ...> |> then(fn %Location{depth: depth, x: x} -> depth * x end)
  150
  """
  def navigate(%Course{} = course) do
    Enum.reduce(course.steps, course.origin, &Location.navigate(&2, &1))
  end

  @doc """
  iex> Course.parse_course("forward 5, up 3, down 2")
  ["forward 5", "up 3", "down 2"]

  iex> Course.parse_course("
  ...>  forward 5
  ...>  up 3
  ...>  down 2
  ...> ")
  ["forward 5", "up 3", "down 2"]
  """
  def parse_course(course) when is_binary(course) do
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
end
