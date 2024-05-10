defmodule Http.Listener do
  require Logger
  use Agent

  def start_link(port) do
    Logger.info("Starting listener on #{port}")

    Agent.start_link(
      fn ->
        spawn(fn -> accept(port) end)
      end,
      name: __MODULE__
    )
  end

  def accept(port) do
    Logger.info("Creating listener socket")

    {:ok, listener_socket} =
      :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    do_accept(listener_socket)
  end

  @spec do_accept(:gen_tcp.socket()) :: nil
  defp do_accept(socket) do
    Logger.info("Accepting next connection")
    {:ok, client} = :gen_tcp.accept(socket)
    # Logger.info("Serving connection for #{to_string(client)}")

    Http.ConnectionQueue.add_connection(client)

    do_accept(socket)
  end
end
