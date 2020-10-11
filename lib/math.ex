defmodule AntlUtilsElixir.Math do
  @moduledoc """
  Useful math functions
  """

  @doc """
    Arithmetic exponentiation

    ## Examples

        iex> Math.pow(2, 0)
        1
        iex> Math.pow(2, 3)
        8
        iex> Math.pow(2, -1)
        0.5
        iex> Math.pow(-1, 0)
        1
        iex> Math.pow(-2, 2)
        4
        iex> Math.pow(-2, 3)
        -8
  """
  @spec pow(integer, integer) :: integer
  def pow(n, k) when is_integer(n) and is_integer(k) and k < 0, do: 1 / pow(n, -1 * k, 1)
  def pow(n, k) when is_integer(n) and is_integer(k), do: pow(n, k, 1)

  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end
