defmodule IslandsEngine.Board do
  # Actions that a board needs to do:
  # 1. Position islands
  # 2. Ensure all islands are positioned/placed
  # 3. Guess coordinates

  alias IslandsEngine.{Island, Coordinate}

  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  def all_islands_positioned?(board) do
    Enum.all?(Island.types(), &Map.has_key?(board, &1))
  end

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    # check whether guess was a hit or miss
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({key, island}, board) do
    # if guess was a hit, check if guess forested the island
    # and if player won the game
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  defp forest_check(board, key) do
    # return wth either :none or type of island was forested
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    # function pass through to Island.forested?
    # pipes board into Map.fetch to retrieve the Island struct
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    # return :win or :no_win
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_forested?(board) do
    Enum.all?(board, fn {_key, island} ->
      Island.forested?(island)
    end)
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlap?(island, new_island)
    end)
  end

  def new() do
    %{}
  end
end
