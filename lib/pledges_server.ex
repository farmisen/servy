defmodule Servy.PledgesServer do
  def recent_pledges() do
    send(self(), {self(), :recent_pledges})

    receive do
      {:result, pledges} -> pledges
    end
  end

  def create_pledge(name, amount) do
    IO.puts("Creating #{amount} pledge for #{name}")

    case send_pledge(name, amount) do
      {:ok, id} ->
        send(self(), {:create_pledge, {id, name, amount}})
    end
  end

  def listen_loop(state \\ []) do
    IO.puts("Waiting for msg...")

    receive do
      {caller, :create_pledge, name, amount} ->
        IO.puts("Creating #{amount} pledge for #{name}")

        case send_pledge(name, amount) do
          {:ok, id} ->
            send(caller, {:result, {id, name, amount}})

            [{id, name, amount} | state]
            |> Enum.slice(0..2)
            |> listen_loop()
        end

      {caller, :recent_pledges} ->
        IO.puts("Returning recent pledges: #{inspect(state)}")

        send(caller, {:result, state})
    end

    listen_loop(state)
  end

  defp send_pledge(name, amount) do
    IO.puts("Sending #{amount} pledge for #{name}")
    {:ok, "pledged-#{:random.uniform(1000)}"}
  end
end
