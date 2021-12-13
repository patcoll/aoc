defmodule Fish.EfficientWorld do
  defstruct ages: %{}

  @doc """
  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  %Fish.EfficientWorld{ages: %{
    0 => 0,
    1 => 1,
    2 => 1,
    3 => 2,
    4 => 1,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 0
  }}
  """
  def create(input) when is_binary(input) do
    ages =
      for i <- 0..Fish.default_age do
        {i, 0}
      end
      |> Map.new()

    ages =
      input
      |> Input.parse_fish()
      |> Enum.reduce(ages, fn age, ages ->
        Map.put(ages, age, ages[age] + 1)
      end)

    %__MODULE__{ages: ages}
  end

  @doc """
  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.step()
  %Fish.EfficientWorld{ages: %{
    0 => 1,
    1 => 1,
    2 => 2,
    3 => 1,
    4 => 0,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 0
  }}

  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.step()
  ...> |> Fish.EfficientWorld.step()
  %Fish.EfficientWorld{ages: %{
    0 => 1,
    1 => 2,
    2 => 1,
    3 => 0,
    4 => 0,
    5 => 0,
    6 => 1,
    7 => 0,
    8 => 1
  }}
  """
  def step(%__MODULE__{ages: existing_ages}) do
    ages =
      (0..Fish.default_age-1)
      |> Enum.reduce(existing_ages, fn age, ages_acc ->
        Map.put(ages_acc, age, ages_acc[age + 1])
      end)
      |> Map.put(Fish.default_age, existing_ages[0])
      |> Map.update(Fish.after_spawn_age, 0, fn val -> val + existing_ages[0] end)

    %__MODULE__{ages: ages}
  end

  @doc """
  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.step_times(18)
  ...> |> Fish.EfficientWorld.count()
  26

  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.step_times(80)
  ...> |> Fish.EfficientWorld.count()
  5934

  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.step_times(256)
  ...> |> Fish.EfficientWorld.count()
  26984457539
  """
  def step_times(%__MODULE__{} = existing_world, number_of_times) when is_integer(number_of_times) do
    (0..number_of_times-1)
    |> Enum.reduce(existing_world, fn _, world ->
      step(world)
    end)
  end

  @doc """
  iex> Fish.EfficientWorld.create("3,4,3,1,2")
  ...> |> Fish.EfficientWorld.count()
  5
  """
  def count(%__MODULE__{ages: ages}) do
    ages
    |> Map.values()
    |> Enum.sum()
  end
end
