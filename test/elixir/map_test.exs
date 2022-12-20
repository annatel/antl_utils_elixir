defmodule AntlUtilsElixir.MapTest do
  use ExUnit.Case
  doctest AntlUtilsElixir.Map

  import AntlUtilsElixir.Map

  defmodule Whatever, do: defstruct(anything: 42)

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

    test "maps with struct values are not considered multilevel" do
      old = %{"one" => 1, :two => %Whatever{}}
      new = %{one: 1, two: %Whatever{}}

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

    test "maps with struct values are not considered multilevel" do
      old = %{"one" => 1, :two => %Whatever{}}
      new = %{"one" => 1, "two" => %Whatever{}}

      assert stringify_keys(old) == new
    end

    test "map with non string or atom keys crash" do
      assert_raise FunctionClauseError, fn -> stringify_keys(%{1 => 1}) end
      assert_raise FunctionClauseError, fn -> stringify_keys(%{{} => 1}) end
      assert_raise FunctionClauseError, fn -> stringify_keys(%{%{} => 1}) end
    end
  end

  describe "transform_keys" do
    test "non map crashes" do
      assert_raise FunctionClauseError, fn -> transform_keys(nil, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys(:anything, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys("anything", &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys(42, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys({}, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys([], &Macro.camelize(&1)) end
    end

    test "struct crashes" do
      assert_raise FunctionClauseError, fn -> transform_keys(%Whatever{}, &Macro.camelize(&1)) end
    end

    test "empty map gives empty map" do
      old = %{}
      new = old

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "single level map with camelized keys remains the same" do
      old = %{"One" => 1, "TwoTwo" => 2}
      new = old

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "single level map with underscored keys is changed to camelized keys, with same text for keys and same content" do
      old = %{"one" => 1, "two_two" => 2}
      new = %{"One" => 1, "TwoTwo" => 2}

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "single level map with mixed underscored and camelized keys is changed to camelized keys, with same text for keys and same content" do
      old = %{"One" => 1, "two_two" => 2}
      new = %{"One" => 1, "TwoTwo" => 2}

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "underscored and camelized keys of multi level map are all transformed" do
      old = %{"One" => 1, "two_two" => %{"ThreeThree" => 3, "four_four" => 4}}
      new = %{"One" => 1, "TwoTwo" => %{"ThreeThree" => 3, "FourFour" => 4}}

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "maps with struct values are not considered multilevel" do
      old = %{"One" => 1, "two_two" => %Whatever{}}
      new = %{"One" => 1, "TwoTwo" =>  %Whatever{}}

      assert transform_keys(old, &Macro.camelize(&1)) == new
    end

    test "map with non string or atom keys crash" do
      assert_raise FunctionClauseError, fn -> transform_keys(%{1 => 1}, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys(%{{} => 1}, &Macro.camelize(&1)) end
      assert_raise FunctionClauseError, fn -> transform_keys(%{%{} => 1}, &Macro.camelize(&1)) end
    end
  end

end
