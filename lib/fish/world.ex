defmodule Fish.World do
  defstruct fish: []

  @doc """
  iex> Fish.World.create("3,4,3,1,2")
  %Fish.World{fish: [ %Fish{age: 3}, %Fish{age: 4}, %Fish{age: 3}, %Fish{age: 1}, %Fish{age: 2} ]}
  """
  def create(input) when is_binary(input) do
    fish =
      input
      |> Input.parse_fish()
      |> Enum.map(&Fish.create/1)

    __MODULE__.create(fish)
  end

  def create(fish) when is_list(fish) do
    %__MODULE__{fish: fish}
  end

  @doc """
  iex> Fish.World.create("3,4,3,1,2")
  ...> |> Fish.World.step()
  %Fish.World{fish: [%Fish{age: 2}, %Fish{age: 3}, %Fish{age: 2}, %Fish{age: 0}, %Fish{age: 1}]}

  iex> Fish.World.create("3,4,3,1,2")
  ...> |> Fish.World.step()
  ...> |> Fish.World.step()
  %Fish.World{fish: [%Fish{age: 1}, %Fish{age: 2}, %Fish{age: 1}, %Fish{age: 6}, %Fish{age: 0}, %Fish{age: 8}]}
  """
  def step(%__MODULE__{fish: fish}) do
    aged_fish =
      fish
      |> Enum.map(fn fish ->
        cond do
          Fish.should_spawn?(fish) ->
            Fish.create(Fish.after_spawn_age)
          true ->
            Fish.create(fish.age - 1)
        end
      end)

    number_to_spawn =
      fish
      |> Enum.map(&Fish.should_spawn?/1)
      |> Enum.filter(&Function.identity/1)
      |> Enum.count()

    new_fish =
      for i <- 0..number_to_spawn, i > 0 do
        Fish.create()
      end

    __MODULE__.create(aged_fish ++ new_fish)
  end

  @doc """
  iex> Fish.World.create("3,4,3,1,2")
  ...> |> Fish.World.step_times(18)
  ...> |> Fish.World.count()
  26

  iex> Fish.World.create("3,4,3,1,2")
  ...> |> Fish.World.step_times(80)
  ...> |> Fish.World.count()
  5934

  # iex> Fish.World.create("3,4,3,1,2")
  # ...> |> Fish.World.step_times(256)
  # ...> |> Fish.World.count()
  # 5934
  """
  def step_times(%__MODULE__{} = existing_world, number_of_times) when is_integer(number_of_times) do
    (0..number_of_times-1)
    |> Enum.reduce(existing_world, fn _, world ->
      step(world)
    end)
  end

  def count(%__MODULE__{fish: fish}) do
    length(fish)
  end
end
