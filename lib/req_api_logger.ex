defmodule AntlUtilsElixir.ReqApiLogger do
  @moduledoc """
  Req Logging plugin tailored for API clients
  """
  require Logger
  alias Req.Request
  alias Req.Response

  @default_log_level :info

  @doc """
  Installs request, response, and error steps that log API calls

  ## Options

    * `:api_name` (mandatory) - name of the api; will be available to the app as metadata
    * `:log_level` (default `:info`) - level at which then logging is done
    * `:hide_request_keys` (default `[]`) - list of request keys that should be hidden (for json or form requests)
    * `:hide_response_keys` (default `[]`) - list of response keys that should be hidden (for json responses)
    * `:hide_request_headers` (default `[]`) - list of request headers that should be hidden
    * `:hide_response_headers` (default `[]`) - list of response headers (and trailers) that should be hidden

  These same options can also be passed through `Req` options to change the
  behavior on a per-request basis.

  ## Examples

  By default, log requests, responses and errors at level :debug with name "my_api" in metadata

      req = Req.new() |> ReqTelemetry.attach(api_name: "my_api", log_level: :debug)

      # send request, log with options passed to attach/1
      Req.get!(req, url: "https://example.org")

      # on this request only, log at level :warning, while hiding keys from the request query and response headers
      Req.get!(req,
        json: %{login: "foo", password: "bar"}
        url: "https://example.org",
        log_level: :warning,
        hide_request_keys: ["password"],
        hide_response_headers: ["x-private-header"]
      )

  """
  def attach(%Request{} = req, opts \\ []) do
    req
    |> Request.register_options([
      :log_level,
      :api_name,
      :hide_request_keys,
      :hide_request_headers,
      :hide_response_keys,
      :hide_response_headers
    ])
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
  defp log_level(req), do: Request.get_option(req, :log_level, @default_log_level)

  defp metadata({req, _}), do: metadata(req)
  defp metadata(req), do: [api_name: api_name(req), api_request_id: request_id(req)]

  defp api_name(req), do: Request.get_option(req, :api_name)
  defp request_id(req), do: Request.get_private(req, :api_request_id)

  defp ms_duration(req) do
    (System.monotonic_time() - Request.get_private(req, :api_start_time))
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp format(req = %Request{}) do
    hide_keys =
      Request.get_option(req, :hide_request_keys, [])
      |> Enum.map(&to_string/1)

    hide_headers =
      Request.get_option(req, :hide_request_headers, [])
      |> Enum.map(&to_string/1)

    method = "#{req.method}" |> String.upcase()
    url = "#{req.url}"
    headers = format_request_headers(req, hide_headers)
    body = format_request_body(req, hide_keys)
    "Sent #{method} #{url} headers=#{headers} body=#{body}"
  end

  defp format({req, %Response{} = resp}) do
    hide_keys =
      Request.get_option(req, :hide_response_keys, [])
      |> Enum.map(&to_string/1)

    hide_headers =
      Request.get_option(req, :hide_response_headers, [])
      |> Enum.map(&to_string/1)

    status = "#{resp.status}"
    url = "#{req.url}"
    headers = format_response_headers(resp, hide_headers)
    trailers = inspect(resp.trailers)
    body = format_response_body(resp, hide_keys)
    duration = ms_duration(req)

    "Received #{status} in #{duration}ms from #{url} headers=#{headers} trailers=#{trailers} body=#{body}"
  end

  defp format({req, error}) do
    url = "#{req.url}"
    error = inspect(error)
    duration = ms_duration(req)
    "API Error in #{duration}ms for #{url} : #{error}"
  end

  defp format_request_body(%Request{} = req, hide_list) do
    case Request.get_header(req, "content-type") do
      ["application/json" <> _] ->
        with {:ok, decoded} <- Jason.decode("#{req.body}") do
          hide(decoded, hide_list)
        else
          _ -> req.body
        end

      ["application/x-www-form-urlencoded"] ->
        req.body
        |> URI.decode_query()
        |> hide(hide_list)

      _ ->
        req.body
    end
    |> inspect()
  end

  defp format_request_headers(req, hide_list), do: hide_and_inspect(req.headers, hide_list)

  defp format_response_body(resp, hide_list), do: hide_and_inspect(resp.body, hide_list)

  defp format_response_headers(resp, hide_list), do: hide_and_inspect(resp.headers, hide_list)

  defp hide_and_inspect(thing, hide_list), do: hide(thing, hide_list) |> inspect()

  defp hide(%{} = map, hide) when is_list(hide),
    do: map |> Enum.map(&hide(&1, hide)) |> Enum.into(%{})

  defp hide(list, hide) when is_list(list) and is_list(hide),
    do: list |> Enum.map(&hide(&1, hide))

  defp hide({k, v}, hide) when is_list(hide),
    do: if(k in hide, do: {k, "[HIDDEN]"}, else: {k, hide(v, hide)})

  defp hide(thing, _), do: thing

  defp generate_request_id do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.url_encode64(binary)
  end
end
