defmodule AntlUtilsElixir.Wildcard do
  def match?(pattern, expr, separator, wildcard_char)
      when is_binary(pattern) and is_binary(expr) do
    with true <- pattern_valid?(pattern, separator),
         true <- expr_valid?(expr, separator, wildcard_char),
         true <- topics_number_equal?(pattern, expr, separator) do
      pattern_as_list = String.split(pattern, separator)
      expr_as_list = String.split(expr, separator)

      Enum.zip(pattern_as_list, expr_as_list)
      |> Enum.reduce(true, &(&2 and equal?(&1, wildcard_char)))
    else
      false -> false
    end
  end

  @spec pattern_valid?(binary, binary) :: boolean
  def pattern_valid?(pattern, separator),
    do: pattern_regex!(separator) |> Regex.match?(pattern)

  defp topics_number_equal?(pattern, expr, separator),
    do:
      pattern |> String.graphemes() |> Enum.count(&(&1 == separator)) ==
        expr |> String.graphemes() |> Enum.count(&(&1 == separator))

  @spec pattern_regex!(binary) :: Regex.t()
  def pattern_regex!(separator) do
    "^(?!\\#{separator})"
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*\\#{separator}$)")
    |> Regex.compile!()
  end

  @spec expr_valid?(binary, binary, binary) :: boolean
  def expr_valid?(expr, separator, wildcard_char),
    do: expr_regex!(separator, wildcard_char) |> Regex.match?(expr)

  @spec expr_regex!(binary, binary) :: Regex.t()
  def expr_regex!(separator, wildcard_char) do
    ("^(?!" <> "\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!^" <> "\\#{wildcard_char}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}\\#{wildcard_char}\\#{separator}" <> ".*" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}\\#{wildcard_char}" <> "$" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}$" <> ")")
    |> Regex.compile!()
  end

  defp equal?({lhs, rhs}, wildcard_char) when lhs in [wildcard_char, rhs], do: true

  defp equal?(_, _), do: false
end
