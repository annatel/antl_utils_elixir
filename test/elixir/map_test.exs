defmodule AntlUtilsElixir.MapTest do
  use ExUnit.Case
  doctest AntlUtilsElixir.Map

  import AntlUtilsElixir.Map

  defmodule Whatever, do: defstruct([])

  describe "atomize_keys" do
    test "non map crashes" do
      assert_raise FunctionClauseError, fn -> atomize_keys(nil) end
      assert_raise FunctionClauseError, fn -> atomize_keys(:anything) end
      assert_raise FunctionClauseError, fn -> atomize_keys("anything") end
      assert_raise FunctionClauseError, fn -> atomize_keys(42) end
      assert_raise FunctionClauseError, fn -> atomize_keys({}) end
      assert_raise FunctionClauseError, fn -> atomize_keys([]) end
    end

    test "struct crashes" do
      assert_raise FunctionClauseError, fn -> atomize_keys(%Whatever{}) end
    end

    test "empty map gives empty map" do
      old = %{}
      new = old

      assert atomize_keys(old) == new
    end

    test "single level map with atom keys remains the same" do
      old = %{one: 1, two: 2}
      new = old

      assert atomize_keys(old) == new
    end

    test "single level map with string keys is changed to atom keys, with same text for keys and same content" do
      old = %{"one" => 1, "two" => 2}
      new = %{one: 1, two: 2}

      assert atomize_keys(old) == new
    end

    test "single level map with mixed atom and string keys is changed to atom keys, with same text for keys and same content" do
      old = %{"one" => 1, :two => 2}
      new = %{:one => 1, :two => 2}

      assert atomize_keys(old) == new
    end

    test "string and atom keys of multi level map are all atomized" do
      old = %{"one" => 1, :two => %{:three => 3, "four" => 4}}
      new = %{one: 1, two: %{three: 3, four: 4}}

      assert atomize_keys(old) == new
    end

    test "map with non string or atom keys crash" do
      assert_raise FunctionClauseError, fn -> atomize_keys(%{1 => 1}) end
      assert_raise FunctionClauseError, fn -> atomize_keys(%{{} => 1}) end
      assert_raise FunctionClauseError, fn -> atomize_keys(%{%{} => 1}) end
    end
  end

  describe "stringify_keys" do
    test "non map crashes" do
      assert_raise FunctionClauseError, fn -> stringify_keys(nil) end
      assert_raise FunctionClauseError, fn -> stringify_keys(:anything) end
      assert_raise FunctionClauseError, fn -> stringify_keys("anything") end
      assert_raise FunctionClauseError, fn -> stringify_keys(42) end
      assert_raise FunctionClauseError, fn -> stringify_keys({}) end
      assert_raise FunctionClauseError, fn -> stringify_keys([]) end
    end

    test "struct crashes" do
      assert_raise FunctionClauseError, fn -> stringify_keys(%Whatever{}) end
    end

    test "empty map gives empty map" do
      old = %{}
      new = old

      assert stringify_keys(old) == new
    end

    test "single level map with string keys remains the same" do
      old = %{"one" => 1, "two" => 2}
      new = old

      assert stringify_keys(old) == new
    end

    test "single level map with atom keys is changed to string keys, with same text for keys and same content" do
      old = %{one: 1, two: 2}
      new = %{"one" => 1, "two" => 2}

      assert stringify_keys(old) == new
    end

    test "single level map with mixed atom and string keys is changed to string keys, with same text for keys and same content" do
      old = %{"one" => 1, :two => 2}
      new = %{"one" => 1, "two" => 2}

      assert stringify_keys(old) == new
    end

    test "string and atom keys of multi level map are all stringified" do
      old = %{"one" => 1, :two => %{:three => 3, "four" => 4}}
      new = %{"one" => 1, "two" => %{"three" => 3, "four" => 4}}

      assert stringify_keys(old) == new
    end

    test "map with non string or atom keys crash" do
      assert_raise FunctionClauseError, fn -> stringify_keys(%{1 => 1}) end
      assert_raise FunctionClauseError, fn -> stringify_keys(%{{} => 1}) end
      assert_raise FunctionClauseError, fn -> stringify_keys(%{%{} => 1}) end
    end
  end
end
