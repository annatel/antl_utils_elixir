defmodule AntlUtilsElixir.String do
  @spec generate_random_string(binary, non_neg_integer) :: binary
  def generate_random_string(alphabet, size) do
    alphabet
    |> String.graphemes()
    |> Enum.shuffle()
    |> Enum.take_random(size)
    |> Enum.join()
  end

  defp imei_with_luhn(<<imei::binary-size(14)>>), do: add_luhn(imei)
  defp imei_with_luhn(imei), do: imei

  defp add_luhn(str) do
    checksum = Luhn.checksum("#{str}0")
    luhn = rem(10 - rem(checksum, 10), 10)
    "#{str}#{luhn}"
  end

  defp imei_to_tac(<<tac::binary-size(8), _rest::binary>>), do: tac
  defp imei_to_tac(_), do: nil

end
