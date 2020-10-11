defmodule RpcClient do
  @moduledoc false

  require Logger

  @spec call(atom, atom, atom, [any]) :: any
  def call(remote_node, module, function_name, attributes)
      when is_atom(module) and is_atom(function_name) and is_list(attributes) do
    Logger.debug("#{remote_node} - #{module} - #{function_name} - #{inspect(attributes)}")

    :rpc.call(remote_node, module, function_name, attributes)
    |> log_response()
    |> process_response()
  end

  defp log_response(response) do
    Logger.debug(inspect(response))

    response
  end

  defp process_response({:badrpc, :nodedown}), do: {:error, :nodedown}

  defp process_response({:badrpc, _error}), do: {:error, :failed}

  defp process_response(response), do: response
end
