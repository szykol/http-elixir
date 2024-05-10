defmodule Http.Server do
  require Logger
  use Agent

  def start_link(port) do
    Logger.info("Starting listener on #{port}")

    Agent.start_link(
      fn ->
        spawn(fn -> consume_connections() end)
      end,
      name: __MODULE__
    )
  end

  defp consume_connections do
    Logger.debug("Consuming connection")

    case Http.ConnectionQueue.pop_connection() do
      nil -> Logger.debug("No incoming connections")
      conn -> Task.async(fn -> serve(conn, :continue) end)
    end

    Logger.debug("Sleeping for 1 second")
    :timer.sleep(:timer.seconds(1))
    consume_connections()
  end

  def serve(client_socket, :continue) do
    Logger.info("Serving client socket")

    parser =
      Http.Parser.init()
      |> Http.Parser.parse_request(client_socket)

    IO.inspect(parser)

    response =
      Http.Response.init()
      |> Http.Response.set_status("200 OK")
      |> Http.Response.set_content("dupajasia")
      |> Http.Response.render()

    client_socket
    |> :gen_tcp.send(response)

    # todo: schedule serving to a worker or something
    serve(client_socket, :stop)
  end

  def serve(_client_socket, :stop) do
    Logger.info("Stopping serving client")
  end
end
