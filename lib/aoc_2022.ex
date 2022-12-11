defmodule Aoc2022 do
  @doc """
  iex> Aoc2022.max_calories("
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
  24000
  """
  def max_calories(elves) when is_binary(elves) do
    elves
    |> Input.parse_elves()
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end
end
