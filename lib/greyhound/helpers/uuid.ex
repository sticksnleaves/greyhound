defmodule Greyhound.Helpers.UUID do
  @moduledoc false

  @uuid_v4 4

  @variant10 2

  @spec v4() :: binary
  def v4() do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)

    uuid_to_string(<<u0::48, @uuid_v4::4, u1::12, @variant10::2, u2::62>>)
  end

  #
  # private
  #

  defp binary_to_hex_list(binary) do
    binary
    |> :binary.bin_to_list()
    |> list_to_hex_str()
  end

  defp list_to_hex_str([]) do
    []
  end

  defp list_to_hex_str([head | tail]) do
    to_hex_str(head) ++ list_to_hex_str(tail)
  end

  defp to_hex(i) when i < 10 do
    0 + i + 48
  end

  defp to_hex(i) when i >= 10 and i < 16 do
    ?a + (i - 10)
  end

  defp to_hex_str(n) when n < 256 do
    [to_hex(div(n, 16)), to_hex(rem(n, 16))]
  end

  defp uuid_to_string(<<u0::32, u1::16, u2::16, u3::16, u4::48>>) do
    IO.iodata_to_binary([
      binary_to_hex_list(<<u0::32>>),
      ?-,
      binary_to_hex_list(<<u1::16>>),
      ?-,
      binary_to_hex_list(<<u2::16>>),
      ?-,
      binary_to_hex_list(<<u3::16>>),
      ?-,
      binary_to_hex_list(<<u4::48>>)
    ])
  end
end
