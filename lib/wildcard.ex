defmodule AntlUtilsElixir.Wildcard do
  def match?(pattern, expr, separator, wildcard_char)
      when is_binary(pattern) and is_binary(expr) do
    plain_expr = expr |> String.replace(separator, "")

    pattern
    |> String.replace(separator, "")
    |> String.replace(wildcard_char, ".+")
    |> then(&("^" <> &1 <> "$"))
    |> Regex.compile!()
    |> Regex.match?(plain_expr)
  end

  def valid_pattern?(pattern, separator, wildcard_char),
    do:
      valid_pattern_regex!(separator, wildcard_char)
      |> Regex.match?(pattern)

  def valid_expr?(expr, separator, wildcard_char),
    do:
      valid_expr_regex!(separator, wildcard_char)
      |> Regex.match?(expr)

  def valid_expr_regex!(separator, wildcard_char) do
    ("^(?!" <> "\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}" <> ".*" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}$" <> ")")
    |> Regex.compile!()
  end

  def valid_pattern_regex!(separator, wildcard_char) do
    "^(?!\\#{separator})"
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}\\#{separator}\\#{wildcard_char}.*)")
    |> Kernel.<>("(?!.*\\#{separator}$)")
    |> Regex.compile!()
  end
end
