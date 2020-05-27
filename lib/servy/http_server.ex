defmodule Servy.HttpServer do
  import Servy.Handler, only: [handle: 1]

  def start(port) when is_integer(port) do
    case :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true]) do
      {:ok, listen_socket} ->
        IO.puts("\nListening for connection on port #{port}...\n")
        accept_loop(listen_socket)
    end
  end

  def accept_loop(listen_socket) do
    IO.puts("Waiting to accept a client connection...\n")

    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        IO.puts("Connection accepted!\n")
        spawn(fn -> serve(client_socket) end)
        accept_loop(listen_socket)
    end
  end

  def serve(client_socket) do
    IO.puts("#{inspect(self())}: Working on it!")

    client_socket
    |> read_request
    |> handle
    |> write_response(client_socket)

    :gen_tcp.close(client_socket)
    IO.puts("#{inspect(self())}: Done with it!")
  end

  def read_request(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, request} ->
        IO.puts("- Received request:\n")
        IO.puts(request)
        request
    end
  end

  def write_response(response, socket) do
    case :gen_tcp.send(socket, response) do
      :ok ->
        IO.puts("<- Sent response:\n")
        IO.puts(response)
    end
  end
end
