defmodule Http.Parser do
  defstruct method: "", path: "", version: "", headers: %{}, content: ""

  def init do
    %Http.Parser{}
  end

  def parse_request(parser, socket) do
    {:ok, reader} = Http.SocketReader.start_link(socket)

    parser
    |> parse_start_line(reader)
    |> parse_headers(reader)
    |> parse_content(reader)
  end

  defp parse_content(parser, reader) do
    case Map.fetch(parser.headers, "Content-Length") do
      :error ->
        parser

      {:ok, length} ->
        case Integer.parse(length) do
          :error -> parser
          {parsed_len, _remainder} -> get_content(parser, reader, parsed_len)
        end
    end
  end

  defp get_content(parser, reader, length) do
    data = Http.SocketReader.read(reader, length)
    %Http.Parser{parser | content: data}
  end

  defp get_next_line(_parser, reader) do
    Http.SocketReader.read_line(reader)
  end

  defp parse_start_line(parser, reader) do
    line = get_next_line(parser, reader)
    [method, path, version] = String.split(line)

    %Http.Parser{parser | method: method, path: path, version: version}
  end

  defp parse_headers(parser, reader) do
    line = get_next_line(parser, reader)

    case do_parse_header(line) do
      {:continue, {header, value}} ->
        headers = Map.put(parser.headers, header, value)
        new_parser = %Http.Parser{parser | headers: headers}
        parse_headers(new_parser, reader)

      :stop_headers ->
        parser
    end
  end

  defp do_parse_header("\r\n") do
    :stop_headers
  end

  defp do_parse_header("") do
    :stop_headers
  end

  defp do_parse_header(line) do
    [header, value] = String.split(line, ": ")
    value = String.trim_trailing(value)
    {:continue, {header, value}}
  end
end
