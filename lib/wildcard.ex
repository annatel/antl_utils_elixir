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

  def valid_expr?(expr, separator) do
    expr_as_list = expr |> String.split(separator)

    expr_as_list
    |> Enum.member?("")
    |> Kernel.not()
  end

  def valid_pattern?(pattern, separator, wildcard_char) do
    valid_expr?(pattern, separator) and
      pattern
      |> String.split(separator)
      |> List.to_string()
      |> Kernel.=~(wildcard_char <> wildcard_char)
      |> Kernel.not()
  end
end
