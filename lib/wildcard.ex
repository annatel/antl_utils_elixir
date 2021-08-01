defmodule AntlUtilsElixir.Wildcard do
  @spec match?(pattern :: binary, expr :: binary, separator :: binary, wildcard_char :: binary) ::
          boolean
  def match?(pattern, expr, separator, wildcard_char)
      when is_binary(pattern) and is_binary(expr) and is_binary(separator) and
             is_binary(wildcard_char) do
    plain_expr = expr |> String.replace(separator, "")

    pattern
    |> String.replace(separator, "")
    |> String.replace(wildcard_char, ".+")
    |> then(&("^" <> &1 <> "$"))
    |> Regex.compile!()
    |> Regex.match?(plain_expr)
  end

  @spec valid_pattern?(binary, binary, binary) :: boolean
  def valid_pattern?(pattern, separator, wildcard_char),
    do:
      valid_pattern_regex!(separator, wildcard_char)
      |> Regex.match?(pattern)

  @spec valid_expr?(binary, binary, binary) :: boolean
  def valid_expr?(expr, separator, wildcard_char),
    do:
      valid_expr_regex!(separator, wildcard_char)
      |> Regex.match?(expr)

  defp valid_expr_regex!(separator, wildcard_char) do
    ("^(?!" <> "\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}" <> ".*" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}$" <> ")")
    |> Regex.compile!()
  end

  defp valid_pattern_regex!(separator, wildcard_char) do
    "^(?!\\#{separator})"
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}\\#{separator}\\#{wildcard_char}.*)")
    |> Kernel.<>("(?!.*\\#{separator}$)")
    |> Regex.compile!()
  end
end
