defmodule AntlUtilsElixir.Enum do
  @doc """
  Invokes the given fun for each item in the enumerable.

  Returns the value of the function that match the pattern {:error, _} otherwise return :ok

  ## Examples

    iex> [1, 2, 3] |> AntlUtilsElixir.Enum.perform(fn x -> {:error, x} end)
    {:error, 1}

    iex> [1, 2, 3] |> AntlUtilsElixir.Enum.perform(fn _x -> :ok end)
    :ok

  """
  @spec perform(any, (any -> any)) :: any
  def perform(enumerable, fun) do
    enumerable
    |> Enum.map(fun)
    |> Enum.filter(&match?({:error, _}, &1))
    |> case do
      [] ->
        :ok

      errors_list when is_list(errors_list) ->
        errors_list |> List.first()
    end
  end
end
