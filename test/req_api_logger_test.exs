defmodule AntlUtilsElixir.ReqApiLoggerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias AntlUtilsElixir.ReqApiLogger

  defp url, do: TestServer.url()
  defp error_url(), do: "http://127.0.0.1:1/"

  defp req_with_logger(opts \\ []) do
    response = opts[:response] || (&Plug.Conn.send_resp(&1, 200, "test_response_body"))

    TestServer.add("/", via: :get, to: response)
    default_opts = [api_name: :test]
    opts = Keyword.delete(opts, :response)

    assert {_, _} =
             Req.new(url: url(), body: "test_request_body", retry: false)
             |> ReqApiLogger.attach(default_opts |> Keyword.merge(opts))
             |> Req.run()
  end

  defp req_error_with_logger() do
    assert {_, _} =
             Req.new(url: error_url(), retry: false)
             |> ReqApiLogger.attach(api_name: "test")
             |> Req.run()
  end

  describe "ReqApiLogger" do
    test "crash on empty empty api_name" do
      assert_raise RuntimeError, fn -> req_with_logger(api_name: nil) end
      TestServer.stop()
    end

    test "logs request method, url, headers and body" do
      assert capture_log(fn -> req_with_logger() end) =~
               ~r/Sent GET #{url()} headers=%{"accept-encoding" => \["gzip"\], "user-agent" => \["req\/[0-9.]+"\]} body="test_request_body"/
    end

    test "logs api_name and request_id in request metadata" do
      assert capture_log(fn -> req_with_logger(api_name: "foobarbaz") end) =~
               ~r/api_name=foobarbaz api_request_id=[^ ]+ Sent GET/
    end

    test "request_id changes for each request" do
      request_id_regex = ~r/ api_request_id=([^ ]+) Sent GET/
      [_, id1] = request_id_regex |> Regex.run(capture_log(fn -> req_with_logger() end))
      [_, id2] = request_id_regex |> Regex.run(capture_log(fn -> req_with_logger() end))

      assert id1 != id2
    end

    test "logs response status, duration, url, headers, trailers and body" do
      assert capture_log(fn -> req_with_logger() end) =~
               ~r/Received 200 in [[:digit:]]+ms from #{url()} headers=%{"cache-control" => \["max-age=0, private, must-revalidate"\], "content-type" => \["text\/html"\], "date" => \["[^"]+"\], "server" => \["[^"]+"\]} trailers=%{} body="test_response_body"/
    end

    test "logs api_name and request_id in response metadata" do
      assert capture_log(fn -> req_with_logger(api_name: "foobarbaz") end) =~
               ~r/api_name=foobarbaz api_request_id=[^ ]+ Received 200/
    end

    test "request_id is the same for request and response" do
      [_, id1, id2] =
        ~r/ api_request_id=([^ ]+) Sent GET.* api_request_id=([^ ]+) Received 200/s
        |> Regex.run(capture_log(fn -> req_with_logger() end))

      assert id1 == id2
    end

    test "logs Req errors" do
      assert capture_log(fn -> req_error_with_logger() end) =~
               ~r/API Error in ([[:digit:]]+)ms for #{error_url()} : %Req.TransportError{reason: :econnrefused}/
    end

    test "logs api_name and request_id in error metadata" do
      assert capture_log(fn -> req_error_with_logger() end) =~
               ~r/api_name=test api_request_id=[^ ]+ API Error /
    end

    test "request_id is the same for request and error" do
      [_, id1, id2] =
        ~r/ api_request_id=([^ ]+) Sent GET.* api_request_id=([^ ]+) API Error /s
        |> Regex.run(capture_log(fn -> req_error_with_logger() end))

      assert id1 == id2
    end

    test "default logging level is :debug" do
      Logger.configure(level: :debug)
      assert capture_log(fn -> req_with_logger() end) =~ ~r/Sent GET/
      Logger.configure(level: :notice)
      assert capture_log(fn -> req_with_logger() end) == ""
      Logger.configure(level: :debug)
    end

    test "each logger can have its own logging level" do
      Logger.configure(level: :notice)
      assert capture_log(fn -> req_with_logger(log_level: :notice) end) =~ ~r/Sent GET/
      Logger.configure(level: :warning)
      assert capture_log(fn -> req_with_logger(log_level: :notice) end) == ""
      Logger.configure(level: :debug)
    end
  end

  # Log timing
end
