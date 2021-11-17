defmodule AntlUtilsElixir.Wildcard do
  @spec match?(pattern :: binary, expr :: binary, separator :: binary, wildcard_char :: binary) ::
          boolean
  def match?(pattern, expr, separator, wildcard_char)
      when is_binary(pattern) and is_binary(expr) and is_binary(separator) and
             is_binary(wildcard_char) do
    pattern
    |> String.replace(separator, "\\.")
    |> String.replace(wildcard_char, ".+")
    |> then(&("^" <> &1 <> "$"))
    |> Regex.compile!()
    |> Regex.match?(expr)
  end

  @spec pattern_valid?(binary, binary, binary) :: boolean
  def pattern_valid?(pattern, separator, wildcard_char),
    do: pattern_regex!(separator, wildcard_char) |> Regex.match?(pattern)

  @spec expr_valid?(binary, binary, binary) :: boolean
  def expr_valid?(expr, separator, wildcard_char),
    do: expr_regex!(separator, wildcard_char) |> Regex.match?(expr)

  @spec expr_regex!(binary, binary) :: Regex.t()
  def expr_regex!(separator, wildcard_char) do
    ("^(?!" <> "\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}" <> ".*" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{separator}$" <> ")")
    |> Regex.compile!()
  end

  @spec pattern_regex!(binary, binary) :: Regex.t()
  def pattern_regex!(separator, wildcard_char) do
    "^(?!\\#{separator})"
    |> Kernel.<>("(?!.*" <> "?" <> "\\#{separator}\\#{separator}" <> ")")
    |> Kernel.<>("(?!.*" <> "\\#{wildcard_char}\\#{separator}\\#{wildcard_char}.*)")
    |> Kernel.<>("(?!.*\\#{separator}$)")
    |> Regex.compile!()
  end
end
