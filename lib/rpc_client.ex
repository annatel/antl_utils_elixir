defmodule AntlUtilsElixir.RpcClient do
  @moduledoc "A tiny Rpc Client"

  defmodule NodeDownError do
    defexception [:message]
  end

  defmodule BadCallError do
    defexception [:message]
  end

  require Logger

  @doc """
  Executes functions on a remote node.
  Logs call and response.

  ## Examples

      iex> AntlUtilsElixir.RpcClient.call(:node, Kernel, :+, [1, 2])
      3

      iex> AntlUtilsElixir.RpcClient.call(:node, Kernel, :undefined_function, [1, 2])
      {:error, :failed}

  """
  @spec call(atom, atom, atom, [any]) :: any
  def call(remote_node, module, function_name, attributes)
      when is_atom(module) and is_atom(function_name) and is_list(attributes) do
    call_and_log(remote_node, module, function_name, attributes)
    |> process_response()
  end

  @doc """
  Similar to `c:call/4` but raises if the call failed.

  ## Examples

      iex> AntlUtilsElixir.RpcClient.call!(:node, Kernel, :+, [1, 2])
      3

      iex> AntlUtilsElixir.RpcClient.call!(:node, Kernel, :undefined_function, [1, 2])
      (** RpcError) got: "failure reason"

  """
  @spec call!(atom, atom, atom, [any]) :: any
  def call!(remote_node, module, function_name, attributes) do
    call_and_log(remote_node, module, function_name, attributes)
    |> process_response!()
  end

  defp call_and_log(remote_node, module, function_name, attributes)
       when is_atom(module) and is_atom(function_name) and is_list(attributes) do
    Logger.debug("#{remote_node} - #{module} - #{function_name} - #{inspect(attributes)}")

    :rpc.call(remote_node, module, function_name, attributes)
    |> log_response()
  end

  defp log_response(response) do
    Logger.debug(inspect(response))

    response
  end

  defp process_response({:badrpc, :nodedown}), do: {:error, :nodedown}

  defp process_response({:badrpc, _error}), do: {:error, :failed}

  defp process_response(response), do: response

  defp process_response!({:badrpc, :nodedown}), do: raise(AntlUtilsElixir.RpcClient.NodeDownError)

  defp process_response!({:badrpc, error}),
    do: raise(AntlUtilsElixir.RpcClient.BadCallError, inspect(error))

  defp process_response!(response), do: response
end
