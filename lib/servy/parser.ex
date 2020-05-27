defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, param_string] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] =
      request_line
      |> String.split(" ")

    headers = header_lines |> parse_headers
    params = param_string |> parse_params(headers["Content-Type"])

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  defp parse_params(params_string, "application/x-www-form-urlencoded"),
    do: params_string |> String.trim() |> URI.decode_query()

  defp parse_params(_, _),
    do: %{}

  def parse_headers([header | header_lines]), do: parse_headers([header | header_lines], %{})

  def parse_headers([], headers), do: headers

  def parse_headers([header | header_lines], headers) do
    [name, value] = String.split(header, ": ")
    parse_headers(header_lines, Map.put(headers, name, value))
  end
end
