defmodule IslandsEngine.Guesses do
  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new() do
    # creates an empty Guesses struct
    %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    # updates the :hit key with the coordinate value
    # in the Guesses struct that are passed as arguments
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    # updates the :miss key with the coordinate value
    # in the Guesses struct that are passed as arguments
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
