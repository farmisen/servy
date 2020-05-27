defmodule Servy.Fetcher do
  def async(fun) do
    caller = self()

    spawn(fn ->
      send(caller, {:result, self(), fun.()})
    end)
  end

  def get_result(pid) do
    receive do
      {:result, ^pid, value} -> value
    end
  end
end
