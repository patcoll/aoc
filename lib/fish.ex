defmodule Fish do
  @default_age 8
  @after_spawn_age 6

  defstruct age: @default_age

  @doc """
  iex> Fish.create("3")
  %Fish{age: 3}

  iex> Fish.create(8)
  %Fish{age: 8}

  iex> Fish.create()
  %Fish{age: 8}
  """
  def create(age) when is_integer(age) do
    %Fish{age: age}
  end

  def create(age) when is_binary(age) do
    %Fish{age: Input.parse_integer(age)}
  end

  def create() do
    create(@default_age)
  end

  def should_spawn?(%Fish{age: 0}), do: true
  def should_spawn?(_), do: false

  def default_age, do: @default_age
  def after_spawn_age, do: @after_spawn_age
end
