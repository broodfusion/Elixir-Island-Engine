defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  # check if an Island has been forested
  def forested?(island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  def guess(island, guess_coordinate) do
    # if guess coordinate is a member of the coordinates sets in island,

    case MapSet.member?(island.coordinates, guess_coordinate) do
      # we need to transform the island by adding the coordinate to
      # the hit coordinate set, and then return a tuple containing :hit
      # and the transformed island.
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, guess_coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end

    # Else, return :miss
  end

  def overlap?(existing_island, new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end

  defp offsets(:square) do
    [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  end

  defp offsets(:atoll) do
    [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  end

  defp offsets(:dot) do
    [{0, 0}]
  end

  defp offsets(:l_shape) do
    [{0, 0}, {1, 0}, {2, 0}, {0, 1}]
  end

  defp offsets(:s_shape) do
    [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  end

  defp offsets(_) do
    {:error, :invalid_island_type}
  end
end
