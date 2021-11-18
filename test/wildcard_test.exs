defmodule AntlUtilsElixir.WildcardTest do
  use ExUnit.Case

  alias AntlUtilsElixir.Wildcard

  @separator "."
  @wildcard_char "*"

  describe "match?/4" do
    test "match all" do
      assert Wildcard.match?(@wildcard_char, "a.b.c", @separator, @wildcard_char)
    end

    test "with one wildcard" do
      assert Wildcard.match?("a.*", "a.b.c", @separator, @wildcard_char)
      refute Wildcard.match?("a.*", "b.b.c", @separator, @wildcard_char)
      refute Wildcard.match?("a.*", "ab.b", @separator, @wildcard_char)
      assert Wildcard.match?("*.c", "a.b.c", @separator, @wildcard_char)
      refute Wildcard.match?("*.c", "a.b.b", @separator, @wildcard_char)
      refute Wildcard.match?("*.c", "e.fc", @separator, @wildcard_char)
    end

    test "with two non-adjacent anchors" do
      assert Wildcard.match?("*.b.*.d.*", "a.b.c.d.e", @separator, @wildcard_char)
      refute Wildcard.match?("*.b.*.d.*", "a.bb.c.dd.e", @separator, @wildcard_char)
      assert Wildcard.match?("*.b.*.d.*", "a.b.c.c.d.e.f", @separator, @wildcard_char)
    end

    test "with three non-adjacent anchors" do
      assert Wildcard.match?("a.*.b.*.c", "a.d.e.b.f.c", @separator, @wildcard_char)
      refute Wildcard.match?("a.*.b.*.c", "a.b.c", @separator, @wildcard_char)
    end

    test "when the pattern does not contain wilcards, return true only for exact match " do
      assert Wildcard.match?("a", "a", @separator, @wildcard_char)
      refute Wildcard.match?("a", "a.b", @separator, @wildcard_char)
    end

    test "when the pattern anchor instance is at the end of the string" do
      assert Wildcard.match?("a.*.b.c", "a.d.e.f.b.c", @separator, @wildcard_char)
      refute Wildcard.match?("a.*.b.c", "a.d.e.b.f.c", @separator, @wildcard_char)
      refute Wildcard.match?("a.*.b.c", "b.c", @separator, @wildcard_char)
    end

    test "when the anchor instance is in the middle of the string" do
      assert Wildcard.match?("*.b.c.*", "a.b.c.d", @separator, @wildcard_char)
      assert Wildcard.match?("a.*.b.c.*.d", "a.e.f.g.b.c.h.d", @separator, @wildcard_char)
      refute Wildcard.match?("a.*.b.c.*.d", "a.e.f.g.b.c.d", @separator, @wildcard_char)
    end

    test "when the anchor instance is at the begining of the string" do
      assert Wildcard.match?("a.b.c.*.d", "a.b.c.g.h.d", @separator, @wildcard_char)
      refute Wildcard.match?("a.b.c.*.d", "a.b.f.e.d", @separator, @wildcard_char)
    end
  end

  describe "expr_valid?/1" do
    test "when the expression is valid, returns true" do
      assert Wildcard.expr_valid?("a.b.c", @separator, @wildcard_char)
    end

    test "when the expression contains two adjacent separators, retuns false" do
      refute Wildcard.expr_valid?("a..b", @separator, @wildcard_char)
    end

    test "when the expression is ended with a separator, returns false" do
      refute Wildcard.expr_valid?("a.b.c.", @separator, @wildcard_char)
    end
  end

  describe "pattern_valid?/1" do
    test "when the pattern is valid, returns true" do
      assert Wildcard.pattern_valid?("a.b.c.*", @separator, @wildcard_char)
    end

    test "when the pattern is not valid_expr, returns false" do
      refute Wildcard.pattern_valid?(".*.a", @separator, @wildcard_char)
    end

    test "when the pattern contains two adjacent wildcards, returns false" do
      refute Wildcard.pattern_valid?("*.*", @separator, @wildcard_char)
      refute Wildcard.pattern_valid?("a.*.*.b", @separator, @wildcard_char)
    end
  end
end
