defmodule AntlUtilsElixir.WildcardTest do
  use ExUnit.Case

  alias AntlUtilsElixir.Wildcard

  @separator "."
  @wildcard_char "+"

  describe "match?/4" do
    test "when the expr match the pattern" do
      assert Wildcard.match?("+", "aa", @separator, @wildcard_char)
      assert Wildcard.match?("+.bb.cc", "aa.bb.cc", @separator, @wildcard_char)
      assert Wildcard.match?("aa.+.cc", "aa.bb.cc", @separator, @wildcard_char)
      assert Wildcard.match?("aa.bb.+", "aa.bb.cc", @separator, @wildcard_char)
      assert Wildcard.match?("aa.+.+", "aa.bb.cc", @separator, @wildcard_char)
      assert Wildcard.match?("+.+.cc", "aa.bb.cc", @separator, @wildcard_char)
      assert Wildcard.match?("+.+.+", "aa.bb.cc", @separator, @wildcard_char)
    end

    test "when the expr number of topics doesnt match the pattern number of topics " do
      refute Wildcard.match?("+", "aa.bb", @separator, @wildcard_char)
      refute Wildcard.match?("aa.+", "aa.bb.cc", @separator, @wildcard_char)
      refute Wildcard.match?("aa.+", "aa", @separator, @wildcard_char)
    end

    test "when the expr doesnt match" do
      refute Wildcard.match?("aa.+", "bb.aa", @separator, @wildcard_char)
    end
  end

  describe "expr_valid?/1" do
    test "when the expression is valid, return true" do
      assert Wildcard.expr_valid?("a.b.c", @separator, @wildcard_char)
    end

    test "when the expression is invalid, retun false" do
      refute Wildcard.expr_valid?("aa.", @separator, @wildcard_char)
      refute Wildcard.expr_valid?("aa..bb", @separator, @wildcard_char)
      refute Wildcard.expr_valid?(".aa", @separator, @wildcard_char)
      refute Wildcard.expr_valid?("aa.+", @separator, @wildcard_char)
    end
  end

  describe "pattern_valid?/1" do
    test "when the pattern is valid, return true" do
      assert Wildcard.pattern_valid?("+.+", @separator)
      assert Wildcard.pattern_valid?("aa.+.+", @separator)
      assert Wildcard.pattern_valid?("+.+.aa", @separator)
      assert Wildcard.pattern_valid?("a.b.c.+", @separator)
      assert Wildcard.pattern_valid?("a.+.c.+", @separator)
    end

    test "when the pattern is invalid, return false" do
      refute Wildcard.pattern_valid?(".", @separator)
      refute Wildcard.pattern_valid?("aa.", @separator)
      refute Wildcard.pattern_valid?(".aa", @separator)
      refute Wildcard.pattern_valid?("..aa", @separator)
      refute Wildcard.pattern_valid?("aa..", @separator)
    end
  end
end
