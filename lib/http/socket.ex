defmodule Http.SocketReader do
  defstruct unparsed: "", lines: [], socket: nil

  use GenServer
  require Logger

  @bufsize 0
  @newline "\r\n"

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    {:ok, %Http.SocketReader{socket: socket}}
  end

  def read_line(reader) do
    GenServer.call(reader, :read_line)
  end

  def read(reader, length) do
    GenServer.call(reader, {:read, length})
  end

  def handle_call(:read_line, _, reader) do
    Logger.debug("Handling read_line")

    reader =
      case Enum.empty?(reader.lines) do
        true -> fetch_data(reader, reader.socket)
        false -> reader
      end

    [line | rest] = reader.lines
    Logger.debug("Returning #{line}")
    Logger.debug("Leaving #{rest}")

    {:reply, line, %Http.SocketReader{reader | lines: rest}}
  end

  def handle_call({:read, length}, _, reader) do
    Logger.debug("Handling read")
    <<value::binary-size(length), rest::binary>> = reader.unparsed

    Logger.debug("Returning #{value}")
    Logger.debug("Leaving #{rest}")
    {:reply, value, %Http.SocketReader{reader | unparsed: rest}}
  end

  defp fetch_data(reader, socket) do
    Logger.debug("Fetching more data from socket #{@bufsize}")

    {:ok, data} = :gen_tcp.recv(socket, @bufsize)

    data = data <> reader.unparsed
    Logger.debug("Data: #{data}")

    splitted_lines = String.split(data, @newline)
    Logger.debug("Splitted lines: #{splitted_lines}")

    unless String.ends_with?(data, @newline) do
      {popped, splitted_lines} = List.pop_at(splitted_lines, -1)

      %Http.SocketReader{reader | unparsed: popped, lines: splitted_lines}
    else
      %Http.SocketReader{reader | lines: splitted_lines}
    end
    |> IO.inspect()
  end
end
