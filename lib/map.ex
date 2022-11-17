defmodule AntlUtilsElixir.Map do
  @moduledoc false

  @doc """
  Populate a nested map or a nested list of map with the parent_key's value

  Returns a new map with the value populated

  ## Examples

      iex> %{key: "value", child: %{}} |> AntlUtilsElixir.Map.populate_child(:key, :child)
      %{key: "value", child: %{key: "value"}}

      iex> %{key: "value", child: %{key: "old_value"}} |> AntlUtilsElixir.Map.populate_child(:key, :child)
      %{key: "value", child: %{key: "value"}}

      iex> %{key: "value", child: [%{}, %{}]} |> AntlUtilsElixir.Map.populate_child(:key, :child)
      %{key: "value", child: [%{key: "value"}, %{key: "value"}]}

      iex> %{key: "value", child: %{}} |> AntlUtilsElixir.Map.populate_child(:not_existing_key, :child)
      %{key: "value", child: %{not_existing_key: nil}}

      iex> %{key: "value", child: %{}} |> AntlUtilsElixir.Map.populate_child(:key, :not_existing_child)
      %{key: "value", child: %{}}

  """
  @spec populate_child(map, any, any) :: map
  def populate_child(map, parent_key, child_key) when is_map(map) do
    value = Map.get(map, parent_key)

    Map.new(map, fn
      {^child_key, child} when is_list(child) ->
        {child_key, Enum.map(child, &put_in(&1, [parent_key], value))}

      {^child_key, child} when is_map(child) ->
        {child_key, put_in(child, [parent_key], value)}

      x ->
        x
    end)
  end

  @doc """
  Puts the given value under key if fun is truthy.

  ## Examples

      iex> %{} |> AntlUtilsElixir.Map.maybe_put(:key, "value", &(not is_nil(&1)))
      %{key: "value"}

      iex> %{} |> AntlUtilsElixir.Map.maybe_put(:key, nil, &(not is_nil(&1)))
      %{}

      iex> %{} |> AntlUtilsElixir.Map.maybe_put(:key, "value1", &(&1 in ["value1", "value2"]))
      %{key: "value1"}

  """
  @spec maybe_put(map, any, any, (any -> boolean)) :: map
  def maybe_put(map, key, value, fun) when is_function(fun, 1) do
    if fun.(value), do: map |> Map.put(key, value), else: map
  end

  @doc """
  Set all keys in a map and all included maps to atoms recursively. The keys in the input map must be either atoms or strings.

  ### Examples

  iex> AntlUtilsElixir.Map.atomize_keys(%{"a" => 1, :b => 2, nil => %{true => 3}})
  %{a: 1, b: 2, nil: %{true: 3}}
  """
  @spec atomize_keys(map) :: map
  def atomize_keys(map) do
    transform_keys(map, fn key -> if is_binary(key), do: String.to_atom(key), else: key end)
  end

  @doc """
  Set all keys in a map and all included maps to strings recursively. The keys in the input map must be either atoms or strings.

  ### Examples

  iex> AntlUtilsElixir.Map.stringify_keys(%{"a" => 1, :b => 2, nil => %{true => 3}})
  %{"a" => 1, "b" => 2, "nil" => %{"true" => 3}}
  """
  @spec stringify_keys(map) :: map
  def stringify_keys(map) do
    transform_keys(map, fn key -> if is_atom(key), do: Atom.to_string(key), else: key end)
  end

  @spec transform_keys(map, function) :: map
  defp transform_keys(map, transform_function) when is_map(map) and not is_struct(map) do
    Map.new(map, fn
      {key, val} when is_atom(key) or is_binary(key) ->
        new_key = transform_function.(key)

        new_val =
          if is_map(val) and not is_struct(val),
            do: transform_keys(val, transform_function),
            else: val

        {new_key, new_val}
    end)
  end
end
