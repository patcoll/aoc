defmodule Crab do
  defstruct position: 0

  def create(position) when is_integer(position) do
    %__MODULE__{position: position}
  end
end
