defmodule Crab.World do
  defstruct crabs: []

  @doc """
  iex> Crab.World.create("16,1,2,0,4,2,7,1,2,14")
  %Crab.World{crabs: [%Crab{position: 16}, %Crab{position: 1}, %Crab{position: 2}, %Crab{position: 0}, %Crab{position: 4}, %Crab{position: 2}, %Crab{position: 7}, %Crab{position: 1}, %Crab{position: 2}, %Crab{position: 14}]}
  """
  def create(input) when is_binary(input) do
    crabs =
      input
      |> Input.parse_delimited_input()
      |> Enum.map(&Input.parse_integer/1)
      |> Enum.map(&Crab.create/1)

    %__MODULE__{crabs: crabs}
  end

  @doc """
  iex> Crab.World.create("16,1,2,0,4,2,7,1,2,14")
  ...> |> Crab.World.find_shortest_distance_to_alignment()
  37
  """
  def find_shortest_distance_to_alignment(%__MODULE__{crabs: crabs}) do
    %{min: %Crab{position: min}, max: %Crab{position: max}} =
      crabs
      |> find_min_and_max_crabs_by_position()

    min..max
    |> Enum.map(fn target_position ->
      sum_of_distances =
        crabs
        |> Enum.map(fn %Crab{position: crab_position} ->
          abs(target_position - crab_position)
        end)
        |> Enum.sum()

      sum_of_distances
    end)
    |> Enum.min()
  end

  defp find_min_and_max_crabs_by_position([%Crab{} | _] = crabs) do
    sorted =
      crabs
      |> Enum.sort_by(&(&1.position))

    %{min: List.first(sorted), max: List.last(sorted)}
  end
end
