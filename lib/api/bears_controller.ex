defmodule Servy.Api.BearsController do
  alias Servy.Conv
  alias Servy.Wildthings

  def index(%Conv{} = conv) do
    result = Wildthings.list_bears() |> Jason.encode()

    case result do
      {:ok, encoded} ->
        %{conv | resp_body: encoded, resp_content_type: "application/json", status: 200}

      {:error, error} ->
        %{conv | resp_body: error.message, resp_content_type: "application/json", status: 500}
    end
  end
end
