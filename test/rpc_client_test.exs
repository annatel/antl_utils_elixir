defmodule RpcClientTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  @node :"node1@127.0.0.1"

  test "when node is down" do
    assert {:error, :nodedown} = RpcClient.call(:node, Kernel, :+, [1, 2])

    assert capture_log(fn -> RpcClient.call(:node, Atom, :to_string, [:atom]) end) =~
             "node - Elixir.Atom - to_string - [:atom]"

    assert capture_log(fn -> RpcClient.call(:node, Atom, :to_string, [:atom]) end) =~
             "{:badrpc, :nodedown}"
  end

  @tag :distributed
  test "when node is up and the call failed" do
    assert {:error, :failed} = RpcClient.call(@node, Kernel, :unexisting_function, [:atom])

    assert capture_log(fn -> RpcClient.call(@node, Kernel, :to_string, [:atom]) end) =~
             "#{@node} - Elixir.Kernel - to_string - [:atom]"

    assert capture_log(fn -> RpcClient.call(@node, Kernel, :to_string, [:atom]) end) =~
             "{:badrpc,"
  end

  @tag :distributed
  test "when node is up " do
    assert 3 = RpcClient.call(@node, Kernel, :+, [1, 2])

    assert capture_log(fn -> RpcClient.call(@node, Atom, :to_string, [:atom]) end) =~
             "#{@node} - Elixir.Atom - to_string - [:atom]"

    assert capture_log(fn -> RpcClient.call(@node, Atom, :to_string, [:atom]) end) =~
             "3"
  end
end
