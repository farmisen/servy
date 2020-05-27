defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            resp_content_type: "text/html",
            resp_body: "",
            status: nil,
            params: %{},
            headers: %{}

  def full_status(conv), do: "#{conv.status} #{status_reason(conv.status)}"

  defp status_reason(code),
    do:
      %{
        200 => "OK",
        201 => "Created",
        404 => "Not Found",
        500 => "Server Error"
      }[code]
end
