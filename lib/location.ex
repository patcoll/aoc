defmodule Location do
  defstruct aim: 0, depth: 0, x: 0

  def old_navigate(%__MODULE__{} = location, "forward " <> amount) do
    %{location | x: location.x + Input.parse_integer(amount)}
  end

  def old_navigate(%__MODULE__{} = location, "down " <> amount) do
    %{location | depth: location.depth + Input.parse_integer(amount)}
  end

  def old_navigate(%__MODULE__{} = location, "up " <> amount) do
    %{location | depth: location.depth - Input.parse_integer(amount)}
  end

  def navigate(%__MODULE__{} = location, "forward " <> amount_str) do
    amount = Input.parse_integer(amount_str)
    %{location | depth: location.depth + (location.aim * amount), x: location.x + amount}
  end

  def navigate(%__MODULE__{} = location, "down " <> amount_str) do
    amount = Input.parse_integer(amount_str)
    %{location | aim: location.aim + amount}
  end

  def navigate(%__MODULE__{} = location, "up " <> amount_str) do
    amount = Input.parse_integer(amount_str)
    %{location | aim: location.aim - amount}
  end
end
