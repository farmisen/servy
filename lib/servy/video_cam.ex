defmodule Servy.VideoCam do
  def get_snapshot(camera_name) do
    :random.seed(:erlang.monotonic_time())
    :timer.sleep(:random.uniform(1000))
    camera_name <> "-snapshot.jpg"
  end
end
