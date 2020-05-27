defmodule Servy.PledgesController do
  alias Servy.Conv
  alias Servy.PledgesServer

  def index(%Conv{} = conv) do
    pledges = PledgesServer.recent_pledges()
    %{conv | status: 200, resp_body: inspect(pledges)}
  end

  def create(%Conv{} = conv, %{"name" => name, "amount" => amount}) do
    PledgesServer.create_pledge(name, String.to_integer(amount))
    %{conv | status: 201, resp_body: "#{name} pledged #{amount}"}
  end
end
