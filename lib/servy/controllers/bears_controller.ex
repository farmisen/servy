defmodule Servy.BearsController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings) do
    body =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | resp_body: body, status: 200}
  end

  def index(%Conv{} = conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | resp_body: "Created a #{type} bear named #{name}!",
        status: 201
    }
  end
end
