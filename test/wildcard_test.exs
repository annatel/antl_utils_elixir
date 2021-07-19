defmodule AntlUtilsElixir.WildcardTest do
  use ExUnit.Case

  alias AntlUtilsElixir.Wildcard

  @default_separator "."
  @default_wildcard_char "*"

  describe "match?/4" do
    test "when there is only wildcard in the pattern, match all" do
      pattern = @default_wildcard_char
      expr = "a.b.c.d.e"

      assert Wildcard.match?(pattern, expr, @default_separator, @default_wildcard_char)
    end

    test "with one wildcard" do
      pattern = "a.*"
      matching_expr = "a.b.c"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "b.b.c"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )

      pattern = "*.a"

      matching_expr = "b.a"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "with two non-adjacent anchors" do
      pattern = "*.b.*.d.*"
      matching_expr = "a.b.c.d.e"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      matching_expr = "a.b.c.c.d.e.f"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "when the pattern does not contain wilcards, return true only for exact match " do
      pattern = "a"
      matching_expr = "a"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "a.b"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "with three non-adjacent anchors" do
      pattern = "a.*.b.*.c"
      matching_expr = "a.d.e.b.f.c"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "a.b.c"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "when the pattern anchor instance is at the end of the string" do
      pattern = "a.*.b.c"
      matching_expr = "a.d.e.f.b.c"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "a.d.e.f.f.c"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "b.c"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "when the anchor instance is in the middle of the string " do
      pattern = "*.b.c.*"
      matching_expr = "a.b.c.d"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      pattern = "a.*.b.c.*.d"
      matching_expr = "a.e.f.g.b.c.h.d"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "a.e.f.g.b.c.d"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end

    test "when the anchor instance is at the begining of the string" do
      pattern = "a.b.c.*.d"
      matching_expr = "a.b.c.g.h.d"

      assert Wildcard.match?(
               pattern,
               matching_expr,
               @default_separator,
               @default_wildcard_char
             )

      unmatching_expr = "a.b.f.e.d"

      refute Wildcard.match?(
               pattern,
               unmatching_expr,
               @default_separator,
               @default_wildcard_char
             )
    end
  end

  describe "valid_expr?/1" do
    test "when the expression contains two adjacent separators retun false" do
      expr = "a..b"
      refute Wildcard.valid_expr?(expr, @default_separator, @default_wildcard_char)
    end

    test "when the expression is ended with separator, return false" do
      expr = "a.b.c."
      refute Wildcard.valid_expr?(expr, @default_separator, @default_wildcard_char)
    end

    test "when the expression is valid, return true" do
      expr = "a.b.c"
      assert Wildcard.valid_expr?(expr, @default_separator, @default_wildcard_char)
    end
  end

  describe "valid_pattern?/1" do
    test "when the pattern is not valid_expr, return false" do
      pattern = ".*.a"
      refute Wildcard.valid_pattern?(pattern, @default_separator, @default_wildcard_char)
    end

    test "when the pattern contains two adjacent wildcards return false" do
      pattern = "*.*"
      refute Wildcard.valid_pattern?(pattern, @default_separator, @default_wildcard_char)

      pattern = "a.*.*.b"
      refute Wildcard.valid_pattern?(pattern, @default_separator, @default_wildcard_char)
    end

    test "when the pattern is valid, return true" do
      pattern = "a.b.c.*"
      assert Wildcard.valid_pattern?(pattern, @default_separator, @default_wildcard_char)
    end
  end
end
