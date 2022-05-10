defmodule AntlUtilsElixir.Keyword do
  @moduledoc false

  @doc """
    Puts the given value under key if fun is truthy.


  ## Examples

      iex> [] |> AntlUtilsElixir.Keyword.maybe_put(:key, "value", &(not is_nil(&1)))
      [key: "value"]

      iex> [] |> AntlUtilsElixir.Keyword.maybe_put(:key, nil, &(not is_nil(&1)))
      []

      iex> [] |> AntlUtilsElixir.Keyword.maybe_put(:key, "value1", &(&1 in ["value1", "value2"]))
      [key: "value1"]

  """
  @spec maybe_put(keyword, any, any, (any -> boolean)) :: keyword
  def maybe_put(keyword, key, value, fun) when is_function(fun, 1) do
    if fun.(value), do: keyword |> Keyword.put(key, value), else: keyword
  end
end
