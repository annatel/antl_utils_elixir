defmodule AntlUtilsElixir.RpcClientTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias AntlUtilsElixir.RpcClient
  alias AntlUtilsElixir.RpcClient.{NodeDownError, BadCallError}

  @node :"node1@127.0.0.1"

  describe "call/4" do
    test "when node is down" do
      assert {:error, :nodedown} = RpcClient.call(:unexisting_node, Kernel, :+, [1, 2])

      assert capture_log(fn -> RpcClient.call(:unexisting_node, Kernel, :+, [1, 2]) end) =~
               "node - Elixir.Kernel - + - [1, 2]"

      assert capture_log(fn -> RpcClient.call(:unexisting_node, Kernel, :+, [1, 2]) end) =~
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

      assert capture_log(fn -> RpcClient.call(@node, Kernel, :+, [1, 2]) end) =~
               "#{@node} - Elixir.Kernel - + - [1, 2]"

      assert capture_log(fn -> RpcClient.call(@node, Kernel, :+, [1, 2]) end) =~
               "3"
    end
  end

  describe "call!/4" do
    test "when node is down" do
      assert_raise NodeDownError, fn ->
        RpcClient.call!(:unexisting_node, Kernel, :+, [1, 2])
      end

      assert capture_log(fn -> RpcClient.call!(:unexisting_node, Kernel, :+, [1, 2]) end) =~
               "node - Elixir.Kernel - + - [1, 2]"

      assert capture_log(fn -> RpcClient.call!(:unexisting_node, Kernel, :+, [1, 2]) end) =~
               "{:badrpc, :nodedown}"
    end

    @tag :distributed
    test "when node is up and the call failed" do
      assert_raise BadCallError, ~r/{:EXIT/, fn ->
        RpcClient.call!(@node, Kernel, :unexisting_function, [:atom])
      end

      assert capture_log(fn ->
               Task.start(fn -> RpcClient.call!(@node, Kernel, :to_string, [:atom]) end)
             end) =~
               "#{@node} - Elixir.Kernel - to_string - [:atom]"

      assert capture_log(fn ->
               Task.start(fn -> RpcClient.call!(@node, Kernel, :to_string, [:atom]) end)
             end) =~
               "{:badrpc,"
    end

    @tag :distributed
    test "when node is up " do
      assert 3 = RpcClient.call!(@node, Kernel, :+, [1, 2])

      assert capture_log(fn ->
               Task.start(fn -> RpcClient.call!(@node, Kernel, :+, [1, 2]) end)
             end) =~
               "#{@node} - Elixir.Kernel - + - [1, 2]"

      assert capture_log(fn ->
               Task.start(fn -> RpcClient.call!(@node, Kernel, :+, [1, 2]) end)
             end) =~
               "3"
    end
  end
end
