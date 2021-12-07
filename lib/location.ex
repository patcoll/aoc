defmodule Location do
  defstruct depth: 0, x: 0

  def navigate(%__MODULE__{} = location, "forward " <> amount) do
    %{location | x: location.x + parse_amount(amount)}
  end

  def navigate(%__MODULE__{} = location, "down " <> amount) do
    %{location | depth: location.depth + parse_amount(amount)}
  end

  def navigate(%__MODULE__{} = location, "up " <> amount) do
    %{location | depth: location.depth - parse_amount(amount)}
  end

  defp parse_amount(amount_str) when is_binary(amount_str) do
    {amount_int, _} = Integer.parse(amount_str)
    amount_int
  end
end
