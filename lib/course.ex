defmodule Course do
  defstruct origin: %Location{}, steps: []

  def create(course) when is_binary(course) do
    %Course{steps: Input.parse_delimited_input(course)}
  end

  @doc """
  iex> Course.create("forward 5, down 5, forward 8, up 3, down 8, forward 2")
  ...> |> Course.old_navigate()
  ...> |> then(fn %Location{depth: depth, x: x} -> depth * x end)
  150
  """
  def old_navigate(%Course{} = course) do
    Enum.reduce(course.steps, course.origin, &Location.old_navigate(&2, &1))
  end

  @doc """
  iex> Course.create("forward 5, down 5, forward 8, up 3, down 8, forward 2")
  ...> |> Course.navigate()
  ...> |> then(fn %Location{depth: depth, x: x} -> depth * x end)
  900
  """
  def navigate(%Course{} = course) do
    Enum.reduce(course.steps, course.origin, &Location.navigate(&2, &1))
  end
end
