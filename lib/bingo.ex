defmodule Bingo do
  @off 0
  @on 1

  defstruct previous_index: -1,
            numbers: [],
            boards: [],
            marked: [],
            solved?: false,
            all_solved?: false,
            board_indexes_solved: []

  def create(input) when is_binary(input) do
    bingo_data = Input.parse_bingo(input)

    %{boards: boards} = bingo_data

    marked =
      boards
      |> Enum.map(fn board ->
        Enum.map(board, fn row ->
          Enum.map(row, fn _ -> @off end)
        end)
      end)

    struct(Bingo, Map.merge(Input.parse_bingo(input), %{marked: marked}))
  end

  def step(%Bingo{previous_index: previous_index, numbers: numbers} = bingo_existing) do
    current_index = previous_index + 1
    number = Enum.fetch!(numbers, current_index)

    bingo =
      bingo_existing
      |> mark(number)
      |> Map.put(:previous_index, current_index)

    # Figure out any newly solved boards, and add their indexes to the end.
    # In case there is more than one newly solved, sort them then append them.
    new_board_indexes_solved =
      bingo.board_indexes_solved ++
        Enum.sort(winning_board_indexes(bingo) -- bingo.board_indexes_solved)

    %{
      bingo
      | solved?: solved?(bingo),
        all_solved?: all_solved?(bingo),
        board_indexes_solved: new_board_indexes_solved
    }
  end

  @doc """
  iex> Bingo.create("
  ...> 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
  ...>
  ...> 22 13 17 11  0
  ...>  8  2 23  4 24
  ...> 21  9 14 16  7
  ...>  6 10  3 18  5
  ...>  1 12 20 15 19
  ...>
  ...>  3 15  0  2 22
  ...>  9 18 13 17  5
  ...> 19  8  7 25 23
  ...> 20 11 10 24  4
  ...> 14 21 16 12  6
  ...>
  ...> 14 21 17 24  4
  ...> 10 16 15  9 19
  ...> 18  8 23 26 20
  ...> 22 11 13  6  5
  ...>  2  0 12  3  7
  ...> ")
  ...> |> Bingo.solve()
  ...> |> then(&({&1.solved?, &1.previous_index, Bingo.score(&1)}))
  {true, 11, 4512}
  """
  def solve(%Bingo{} = bingo_input) do
    # step until solved, or we ran out of numbers
    0..(length(bingo_input.numbers) - 1)
    |> Enum.reduce_while(bingo_input, fn _, bingo ->
      bingo = step(bingo)

      if solved?(bingo) or not can_step?(bingo) do
        {:halt, bingo}
      else
        {:cont, bingo}
      end
    end)
  end

  @doc """
  iex> Bingo.create("
  ...> 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
  ...>
  ...> 22 13 17 11  0
  ...>  8  2 23  4 24
  ...> 21  9 14 16  7
  ...>  6 10  3 18  5
  ...>  1 12 20 15 19
  ...>
  ...>  3 15  0  2 22
  ...>  9 18 13 17  5
  ...> 19  8  7 25 23
  ...> 20 11 10 24  4
  ...> 14 21 16 12  6
  ...>
  ...> 14 21 17 24  4
  ...> 10 16 15  9 19
  ...> 18  8 23 26 20
  ...> 22 11 13  6  5
  ...>  2  0 12  3  7
  ...> ")
  ...> |> Bingo.solve_all()
  ...> |> then(&({&1.previous_index, Bingo.score(&1)}))
  {14, 1924}
  """
  def solve_all(%Bingo{} = bingo_input) do
    # step until all solved, or we ran out of numbers
    0..(length(bingo_input.numbers) - 1)
    |> Enum.reduce_while(bingo_input, fn _, bingo ->
      bingo = step(bingo)

      if all_solved?(bingo) or not can_step?(bingo) do
        {:halt, bingo}
      else
        {:cont, bingo}
      end
    end)
  end

  def solved?(%Bingo{} = bingo) do
    bingo
    |> boards_solved()
    |> Enum.any?()
  end

  def all_solved?(%Bingo{} = bingo) do
    bingo
    |> boards_solved()
    |> Enum.all?()
  end

  def score(%Bingo{solved?: true} = bingo) do
    winning_board_index =
      bingo.board_indexes_solved
      |> List.last()

    score_for(bingo, winning_board_index)
  end

  defp can_step?(%Bingo{previous_index: previous_index, numbers: numbers}) do
    not is_nil(Enum.at(numbers, previous_index + 1))
  end

  defp boards_solved(%Bingo{marked: marked}) do
    Enum.map(marked, &marked_board_solved?/1)
  end

  defp score_for(%Bingo{marked: existing_marked} = bingo, board_index) do
    unmarked_numbers_sum =
      existing_marked
      |> Enum.with_index()
      |> Enum.map(fn {board, i} ->
        if i == board_index do
          board
          |> Enum.with_index()
          |> Enum.map(fn {row, j} ->
            row
            |> Enum.with_index()
            |> Enum.map(fn {val, k} ->
              on_board =
                bingo.boards
                |> Enum.at(i)
                |> Enum.at(j)
                |> Enum.at(k)

              if val == @on do
                0
              else
                on_board
              end
            end)
          end)
        else
          []
        end
      end)
      |> List.flatten()
      |> Enum.sum()

    last_number_processed = Enum.at(bingo.numbers, bingo.previous_index)

    unmarked_numbers_sum * last_number_processed
  end

  defp winning_board_indexes(%Bingo{} = bingo) do
    bingo
    |> boards_solved()
    |> Enum.with_index()
    |> Enum.filter(fn {solved, _} -> solved end)
    |> Enum.map(fn {_, index} -> index end)
  end

  defp marked_board_solved?([[el | _] | _] = marked_board) when is_integer(el) do
    any_row_solved? =
      marked_board
      |> Enum.map(&all_elements_solved?/1)
      |> Enum.any?()

    any_column_solved? =
      marked_board
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&all_elements_solved?/1)
      |> Enum.any?()

    any_row_solved? or any_column_solved?
  end

  defp all_elements_solved?([el | _] = row) when is_integer(el) do
    Enum.all?(row, &(&1 == @on))
  end

  defp mark(%Bingo{boards: boards, marked: existing_marked} = bingo, number)
       when is_integer(number) do
    marked =
      existing_marked
      |> Enum.with_index()
      |> Enum.map(fn {board, i} ->
        board
        |> Enum.with_index()
        |> Enum.map(fn {row, j} ->
          row
          |> Enum.with_index()
          |> Enum.map(fn {val, k} ->
            on_board =
              boards
              |> Enum.at(i)
              |> Enum.at(j)
              |> Enum.at(k)

            if on_board == number do
              @on
            else
              val
            end
          end)
        end)
      end)

    %{bingo | marked: marked}
  end
end
