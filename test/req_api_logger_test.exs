defmodule AntlUtilsElixir.ReqApiLoggerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias AntlUtilsElixir.ReqApiLogger

  defp url, do: TestServer.url()
  defp error_url(), do: "http://localhost:1/"

  defp req_new_with_logger(url, opts \\ []) do
    default_opts = [api_name: :test]

    Req.new(url: url, body: "test_request_body", retry: false)
    |> ReqApiLogger.attach(default_opts |> Keyword.merge(opts))
  end

  defp req_run_with_logger(opts \\ []) do
    response = opts[:response] || (&Plug.Conn.send_resp(&1, 200, "test_response_body"))
    TestServer.add("/", via: :get, to: response)
    assert {_, _} = req_new_with_logger(url(), Keyword.delete(opts, :response)) |> Req.run()
  end

  defp req_error_with_logger() do
    assert {_, _} = req_new_with_logger(error_url()) |> Req.run()
  end

  describe "ReqApiLogger" do
    test "crash on empty empty api_name" do
      assert_raise RuntimeError, fn -> req_run_with_logger(api_name: nil) end
      TestServer.stop()
    end

    test "logs request method, url, headers and body" do
      assert capture_log(fn -> req_run_with_logger() end) =~
               ~r/Sent GET #{url()} headers=%{"accept-encoding" => \["gzip"\], "user-agent" => \["req\/[0-9.]+"\]} body="test_request_body"/
    end

    test "logs api_name and request_id in request metadata" do
      assert capture_log(fn -> req_run_with_logger(api_name: "foobarbaz") end) =~
               ~r/api_name=foobarbaz api_request_id=[^ ]+ Sent GET/
    end

    test "be able to log json request with body nil" do
      TestServer.add("/", via: :post)

      assert capture_log(fn ->
               Req.new(url: url(), headers: [{"content-type", "application/json"}])
               |> ReqApiLogger.attach(api_name: :test)
               |> Req.post()
             end) =~
               ~r/body=nil/
    end

    test "request_id changes for each request" do
      request_id_regex = ~r/ api_request_id=([^ ]+) Sent GET/
      [_, id1] = request_id_regex |> Regex.run(capture_log(fn -> req_run_with_logger() end))
      [_, id2] = request_id_regex |> Regex.run(capture_log(fn -> req_run_with_logger() end))

      assert id1 != id2
    end

    test "logs response status, duration, url, headers, trailers and body" do
      assert capture_log(fn -> req_run_with_logger() end) =~
               ~r/Received 200 in [[:digit:]]+ms from #{url()} headers=%{"cache-control" => \["max-age=0, private, must-revalidate"\], "content-type" => \["text\/html"\], "date" => \["[^"]+"\], "server" => \["[^"]+"\]} trailers=%{} body="test_response_body"/
    end

    test "logs api_name and request_id in response metadata" do
      assert capture_log(fn -> req_run_with_logger(api_name: "foobarbaz") end) =~
               ~r/api_name=foobarbaz api_request_id=[^ ]+ Received 200/
    end

    test "request_id is the same for request and response" do
      [_, id1, id2] =
        ~r/ api_request_id=([^ ]+) Sent GET.* api_request_id=([^ ]+) Received 200/s
        |> Regex.run(capture_log(fn -> req_run_with_logger() end))

      assert id1 == id2
    end

    test "be able to hide request headers" do
      TestServer.add("/", via: :post)

      assert capture_log(fn ->
               req_new_with_logger(url())
               |> Req.post(hide_request_headers: ["user-agent"])
             end) =~
               ~r/headers=%{"accept-encoding" => \["gzip"\], "user-agent" => "\[HIDDEN\]"}/
    end

    test "be able to hide json request data" do
      TestServer.add("/", via: :post)

      log =
        capture_log(fn ->
          req_new_with_logger(url())
          |> Req.post(
            hide_request_keys: [:hide1, "hide2"],
            json: %{hide1: "secret", foo: %{hide2: "secret"}, show: "seeme"}
          )
        end)

      assert log =~ ~r/seeme/
      refute log =~ ~r/secret/
      assert log =~ ~r/\[HIDDEN\].*\[HIDDEN\]/
    end

    test "be able to hide form request data" do
      TestServer.add("/", via: :post)

      log =
        capture_log(fn ->
          req_new_with_logger(url())
          |> Req.post(
            hide_request_keys: [:hide1, "hide2"],
            form: %{hide1: "secret", hide2: "secret", show: "seeme"}
          )
        end)

      assert log =~ ~r/seeme/
      refute log =~ ~r/secret/
      assert log =~ ~r/\[HIDDEN\].*\[HIDDEN\]/
    end

    test "be able to hide response headers" do
      TestServer.add("/", via: :post)

      assert capture_log(fn ->
               req_new_with_logger(url())
               |> Req.post(hide_response_headers: ["cache-control", "date"])
             end) =~
               ~r/headers=%{"cache-control" => "\[HIDDEN\]", "content-type" => \["text\/html"\], "date" => "\[HIDDEN\]", "server" => \["[^"]+"\]}/
    end

    test "be able to hide json response data" do
      TestServer.add("/",
        via: :get,
        to: fn conn ->
          data = %{hide1: "secret", foo: %{hide2: "secret"}, show: "seeme"}

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(200, Jason.encode!(data))
        end
      )

      log =
        capture_log(fn ->
          req_new_with_logger(url())
          |> Req.get(hide_response_keys: [:hide1, "hide2"])
        end)

      assert log =~ ~r/seeme/
      refute log =~ ~r/secret/
      assert log =~ ~r/\[HIDDEN\].*\[HIDDEN\]/
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

    test "default logging level is :info" do
      Logger.configure(level: :info)
      assert capture_log(fn -> req_run_with_logger() end) =~ ~r/Sent GET/
      Logger.configure(level: :warning)
      assert capture_log(fn -> req_run_with_logger() end) == ""
      Logger.configure(level: :debug)
    end

    test "log level is configurable" do
      Logger.configure(level: :warning)
      assert capture_log(fn -> req_run_with_logger(log_level: :warning) end) =~ ~r/Sent GET/
      Logger.configure(level: :error)
      assert capture_log(fn -> req_run_with_logger(log_level: :warning) end) == ""
      Logger.configure(level: :debug)
    end
  end
end
