defmodule AntlUtilsElixir.String do
  @spec generate_random_string(binary, non_neg_integer) :: binary
  def generate_random_string(alphabet, size) do
    alphabet
    |> String.graphemes()
    |> Enum.shuffle()
    |> Enum.take_random(size)
    |> Enum.join()
  end
end
