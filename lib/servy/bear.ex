defmodule Servy.Bear do
  @derive {Jason.Encoder, only: [:type, :name, :id, :hibernating]}
  defstruct id: nil,
            name: "",
            type: "",
            hibernating: false

  def isGrizzly(%Servy.Bear{type: type}), do: type == "Grizzly"

  def order_asc_by_name(%Servy.Bear{name: n1}, %Servy.Bear{name: n2}), do: n1 <= n2
end
