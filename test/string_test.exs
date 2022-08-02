defmodule AntlUtilsElixir.StringTest do
  use ExUnit.Case

  test "generate_random_string/2" do
    string_1 = AntlUtilsElixir.String.generate_random_string("abcdefghijklmnopqrstuvwxyz", 2)
    string_2 = AntlUtilsElixir.String.generate_random_string("abcdefghijklmnopqrstuvwxyz", 2)
    assert String.length(string_1) == 2
    assert String.length(string_2) == 2
    assert string_1 != string_2
  end
end
