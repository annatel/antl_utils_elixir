defmodule AntlUtilsElixir.DateTime.Period do
  @moduledoc """
  Period
  """
  alias AntlUtilsElixir.DateTime.Comparison

  @type t :: %{start_at: nil | DateTime.t(), end_at: nil | DateTime.t()}

  @spec included?(map, map, atom, atom) :: boolean
  def included?(a, b, start_at_key, end_at_key)
      when is_map(a) and is_map(b) and is_atom(start_at_key) and is_atom(end_at_key) do
    period_a = %{start_at: Map.get(a, start_at_key), end_at: Map.get(a, end_at_key)}
    period_b = %{start_at: Map.get(b, start_at_key), end_at: Map.get(b, end_at_key)}

    included?(period_a, period_b)
  end

  @spec included?(t, t) :: boolean()
  def included?(%{start_at: %DateTime{}} = a, %{start_at: %DateTime{}, end_at: nil} = b) do
    Comparison.gte?(a.start_at, b.start_at)
  end

  def included?(%{start_at: %DateTime{}, end_at: nil}, %{
        start_at: %DateTime{},
        end_at: %DateTime{}
      }),
      do: false

  def included?(
        %{start_at: %DateTime{}, end_at: %DateTime{}} = a,
        %{start_at: %DateTime{}, end_at: %DateTime{}} = b
      ) do
    Comparison.gte?(a.start_at, b.start_at) &&
      Comparison.lte?(a.end_at, b.end_at)
  end

  @spec get_status(map, DateTime.t(), atom, atom) :: :ended | :ongoing | :scheduled
  def get_status(period, %DateTime{} = datetime, start_at_key, end_at_key)
      when is_map(period) and is_atom(start_at_key) and is_atom(end_at_key) do
    %{
      start_at: Map.get(period, start_at_key),
      end_at: Map.get(period, end_at_key)
    }
    |> get_status(datetime)
  end

  @spec get_status(t, DateTime.t()) :: :ended | :ongoing | :scheduled
  def get_status(%{start_at: start_at, end_at: end_at}, %DateTime{} = datetime) do
    comparaison_with_start_at = DateTime.compare(datetime, start_at)

    comparaison_with_end_at =
      case end_at do
        nil -> :lt
        _ -> DateTime.compare(datetime, end_at)
      end

    case {comparaison_with_start_at, comparaison_with_end_at} do
      {:gt, :lt} ->
        :ongoing

      {:eq, :lt} ->
        :ongoing

      {:lt, _} ->
        :scheduled

      {_, :gt} ->
        :ended

      {_, :eq} ->
        :ended
    end
  end

  @spec filter_by_status([t], atom() | [atom()], DateTime.t(), atom, atom) :: [any]
  def filter_by_status(
        periods,
        status,
        %DateTime{} = datetime,
        start_key \\ :start_at,
        end_key \\ :end_at
      )
      when is_list(periods) and is_atom(start_key) and is_atom(end_key) do
    status = List.wrap(status)

    periods
    |> Enum.filter(&(get_status(&1, datetime, start_key, end_key) in status))
  end
end
