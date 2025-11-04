defmodule AntlUtilsElixir.ReqApiLogger do
  require Logger
  alias Req.Request
  alias Req.Response

  def attach(%Request{} = req, opts \\ []) do
    req
    |> Request.register_options([:log_level, :api_name])
    |> Request.merge_options(opts)
    |> Request.prepend_request_steps(init_log_api: &set_request_id_and_start_time/1)
    |> Request.append_request_steps(log_api: &log/1)
    |> Request.append_response_steps(log_api: &log/1)
    |> Request.append_error_steps(log_api: &log/1)
    |> tap(&(api_name(&1) || raise("please set :api_name option")))
  end

  defp log(what) do
    what
    |> tap(&Logger.log(log_level(&1), format(&1), metadata(&1)))
  end

  defp set_request_id_and_start_time(%Request{} = req) do
    req
    |> Request.put_private(:api_request_id, generate_request_id())
    |> Request.put_private(:api_start_time, System.monotonic_time())
  end

  defp log_level({req, _}), do: log_level(req)
  defp log_level(req), do: Request.get_option(req, :log_level, :debug)

  defp metadata({req, _}), do: metadata(req)
  defp metadata(req), do: [api_name: api_name(req), api_request_id: request_id(req)]

  defp api_name(req), do: Request.get_option(req, :api_name)
  defp request_id(req), do: Request.get_private(req, :api_request_id)

  defp ms_duration(req) do
    (System.monotonic_time() - Request.get_private(req, :api_start_time))
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp format(req = %Request{}) do
    method = "#{req.method}" |> String.upcase()
    url = "#{req.url}"
    headers = inspect(req.headers)
    body = inspect(req.body)
    "Sent #{method} #{url} headers=#{headers} body=#{body}"
  end

  defp format({req, %Response{} = resp}) do
    status = "#{resp.status}"
    url = "#{req.url}"
    headers = inspect(resp.headers)
    trailers = inspect(resp.trailers)
    body = inspect(resp.body)
    duration = ms_duration(req)

    "Received #{status} in #{duration}ms from #{url} headers=#{headers} trailers=#{trailers} body=#{body}"
  end

  defp format({req, error}) do
    url = "#{req.url}"
    error = inspect(error)
    duration = ms_duration(req)
    "API Error in #{duration}ms for #{url} : #{error}"
  end

  defp generate_request_id do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.url_encode64(binary)
  end
end
