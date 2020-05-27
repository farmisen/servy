defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  alias Servy.Conv
  alias Servy.BearsController
  alias Servy.Api.BearsController, as: ApiBearsController
  alias Servy.PledgesController
  alias Servy.VideoCam
  alias Servy.Tracker

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    |> track
    |> format_response
  end

  def handle_file({:ok, content}, %Conv{} = conv), do: %{conv | resp_body: content, status: 200}

  def handle_file({:error, :enoent}, %Conv{} = conv),
    do: handle_error(conv, "Page not found", 404)

  def handle_file({:error, reason}, %Conv{} = conv),
    do: handle_error(conv, "File error: #{reason}", 500)

  def handle_error(%Conv{} = conv, message, status \\ 500),
    do: %{conv | resp_body: "<h1>Error #{status}</h1><h2>#{message}</h2>", status: status}

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgesController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgesController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    ["cam-1", "cam-2", "cam-3"]

    task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      1..10
      |> Enum.map(fn n -> "cam-#{n}" end)
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_big_foot = Task.await(task)

    # pids =
    #   for cam <- ["cam-1", "cam-2", "cam-3"] do
    #     spawn(fn -> VideoCam.get_snapshot(cam, caller) end)
    #   end

    # snapshots =
    #   for pid <- pids do
    #     receive do
    #       {:result, ^pid, filename} -> filename
    #     end
    #   end

    %{conv | resp_body: inspect({snapshots, where_is_big_foot}), status: 200}
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    case Integer.parse(time) do
      {int_time, ""} ->
        int_time
        |> :timer.sleep()

        %{conv | resp_body: "Awake!", status: 200}

      _ ->
        handle_error(conv, "malformed time: #{time}", 500)
    end
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearsController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    BearsController.show(conv, Map.put(conv.params, "id", id))
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearsController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearsController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/" <> page_name} = conv) do
    @pages_path
    |> Path.join(page_name <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
