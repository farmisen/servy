defmodule Servy.Plugins do
  alias Servy.Conv

  @doc "Logs 404 responses"
  def track(%Conv{status: 404} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning #{conv.path} is on the loose!")
    end

    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end
end
