defmodule AntlUtilsElixir.DateTime.PeriodTest do
  use ExUnit.Case, async: true
  doctest AntlUtilsElixir.DateTime.Period

  alias AntlUtilsElixir.DateTime.Period

  @datetime1 DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")
  @datetime2 DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC")
  @datetime3 DateTime.from_naive!(~N[2018-01-03 00:00:00], "Etc/UTC")

  describe "get_status/2" do
    test ":ongoing" do
      assert Period.get_status(%{start_at: @datetime1, end_at: @datetime3}, @datetime2) ==
               :ongoing

      assert Period.get_status(%{start_at: @datetime1, end_at: @datetime2}, @datetime1) ==
               :ongoing

      assert Period.get_status(%{start_at: @datetime1, end_at: nil}, @datetime2) == :ongoing
    end

    test ":ended" do
      assert Period.get_status(%{start_at: @datetime1, end_at: @datetime2}, @datetime3) == :ended

      assert Period.get_status(%{start_at: @datetime1, end_at: @datetime2}, @datetime2) == :ended
    end

    test ":scheduled" do
      assert Period.get_status(%{start_at: @datetime2, end_at: @datetime3}, @datetime1) ==
               :scheduled

      assert Period.get_status(%{start_at: @datetime2, end_at: nil}, @datetime1) == :scheduled
    end
  end

  describe "get_status/4" do
    test "can accept different key name for start_at and end_at" do
      assert Period.get_status(
               %{started_at: @datetime1, ended_at: @datetime3},
               @datetime2,
               :started_at,
               :ended_at
             ) == :ongoing
    end
  end

  describe "filter_by_status/5" do
    test "filter_by_status/3" do
      ended = %{start_at: @datetime1, end_at: @datetime2, id: 1}
      ongoing = %{start_at: @datetime1, end_at: @datetime3, id: 2}
      scheduled = %{start_at: @datetime3, end_at: nil, id: 3}

      periods = [ended, ongoing, scheduled]

      assert Period.filter_by_status(periods, :ended, @datetime2)
             |> Enum.map(& &1.id) == [ended.id]

      assert Period.filter_by_status(periods, :ongoing, @datetime2)
             |> Enum.map(& &1.id) == [ongoing.id]

      assert Period.filter_by_status(periods, :scheduled, @datetime2)
             |> Enum.map(& &1.id) == [scheduled.id]

      filtered_periods_ids =
        Period.filter_by_status(periods, [:ongoing, :scheduled], @datetime2) |> Enum.map(& &1.id)

      assert filtered_periods_ids |> Enum.member?(ongoing.id)
      assert filtered_periods_ids |> Enum.member?(scheduled.id)

      assert Period.filter_by_status(periods, :unknown_status, @datetime2) == []
    end

    test "can accept different key name for start_at and end_at" do
      ongoing = %{started_at: @datetime1, ended_at: @datetime3, id: 2}
      periods = [ongoing]

      assert Period.filter_by_status(periods, :ongoing, @datetime2, :started_at, :ended_at)
             |> Enum.map(& &1.id) == [ongoing.id]
    end
  end

  describe "included?/4" do
    test "can accept different key name for start_at and end_at - when start_at of period A is before start_at of period B, returns false" do
      period_a = %{started_at: @datetime1, ended_at: nil}
      period_b = %{started_at: @datetime2, ended_at: nil}

      assert Period.included?(period_a, period_b, :started_at, :ended_at) == false
    end
  end

  describe "included?/2" do
    test "when start_at of period A is nil, raises a FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        period_a = %{start_at: nil, end_at: @datetime1}
        period_b = %{start_at: @datetime1, end_at: @datetime1}
        Period.included?(period_a, period_b)
      end
    end

    test "when start_at of period B is nil, raises a FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        period_a = %{start_at: @datetime1, end_at: @datetime1}
        period_b = %{start_at: nil, end_at: @datetime1}

        Period.included?(period_a, period_b)
      end
    end

    test "when start_at of period A is before start_at of period B, returns false" do
      period_a = %{start_at: @datetime1, end_at: nil}
      period_b = %{start_at: @datetime2, end_at: nil}

      assert Period.included?(period_a, period_b) == false
    end

    test "when end_at of period A is nil and end_at of period B is set, returns false" do
      period_a = %{start_at: @datetime2, end_at: nil}
      period_b = %{start_at: @datetime1, end_at: @datetime3}

      assert Period.included?(period_a, period_b) == false
    end

    test "when end_at of period A is after end_at of period B, returns false" do
      period_a = %{start_at: @datetime1, end_at: @datetime3}
      period_b = %{start_at: @datetime1, end_at: @datetime2}

      assert Period.included?(period_a, period_b) == false
    end

    test "when start_at and end_at of period A are in bound of start_at and end_at of period B, returns true" do
      period_a = %{start_at: @datetime1, end_at: @datetime2}
      period_b = %{start_at: @datetime1, end_at: @datetime3}

      assert Period.included?(period_a, period_b) == true
    end

    test "when start_at and end_at of period A are equal to start_at and end_at of period B, returns true" do
      period = %{start_at: @datetime1, end_at: @datetime2}

      assert Period.included?(period, period) == true
    end

    test "when end_at of period A is set and end_at of period B is nil, returns true" do
      period_a = %{start_at: @datetime1, end_at: @datetime3}
      period_b = %{start_at: @datetime1, end_at: nil}

      assert Period.included?(period_a, period_b) == true
    end
  end
end
