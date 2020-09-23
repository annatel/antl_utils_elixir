defmodule AntlUtilsElixir.DateTime.Comparison do
  @moduledoc """
  Little wrapper around DateTime
  """

  @doc ~S"""
  Returns whether datetime1 is greater than datetime2

  ## Examples

      iex> Comparison.gt?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.gt?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.gt?(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      true
  """
  @spec gt?(DateTime.t(), DateTime.t()) :: boolean()
  def gt?(%DateTime{} = dt1, %DateTime{} = dt2) do
    DateTime.compare(dt1, dt2) == :gt
  end

  @doc ~S"""
  Returns whether datetime1 is greater than or equal to datetime2

  ## Examples

      iex> Comparison.gte?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.gte?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      true

      iex> Comparison.gte?(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      true
  """
  @spec gte?(DateTime.t(), DateTime.t()) :: boolean()
  def gte?(%DateTime{} = dt1, %DateTime{} = dt2) do
    DateTime.compare(dt1, dt2) in [:eq, :gt]
  end

  @doc ~S"""
  Returns whether datetime1 is less than datetime2

  ## Examples

      iex> Comparison.lt?(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.lt?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.lt?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      true
  """
  @spec lt?(DateTime.t(), DateTime.t()) :: boolean()
  def lt?(%DateTime{} = dt1, %DateTime{} = dt2) do
    DateTime.compare(dt1, dt2) == :lt
  end

  @doc ~S"""
  Returns whether datetime1 is less than or equal to datetime2

  ## Examples

      iex> Comparison.lte?(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      false

      iex> Comparison.lte?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      true

      iex> Comparison.lte?(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      true
  """
  @spec lte?(DateTime.t(), DateTime.t()) :: boolean()
  def lte?(%DateTime{} = dt1, %DateTime{} = dt2) do
    DateTime.compare(dt1, dt2) in [:eq, :lt]
  end

  @doc ~S"""
  Returns the min date between datetime1 and datetime2

  ## Examples

      iex> Comparison.min(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")

      iex> Comparison.min(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")

      iex> Comparison.min(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")
  """
  @spec min(DateTime.t(), DateTime.t()) :: DateTime.t()
  def min(%DateTime{} = dt1, %DateTime{} = dt2) do
    if lt?(dt1, dt2) do
      dt1
    else
      dt2
    end
  end

  @doc ~S"""
  Returns the max date between datetime1 and datetime2

  ## Examples

      iex> Comparison.max(DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC")

      iex> Comparison.max(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")

      iex> Comparison.max(DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC"), DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC"))
      DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC")
  """
  @spec max(DateTime.t(), DateTime.t()) :: DateTime.t()
  def max(%DateTime{} = dt1, %DateTime{} = dt2) do
    if gt?(dt1, dt2) do
      dt1
    else
      dt2
    end
  end
end
