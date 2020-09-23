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
end
