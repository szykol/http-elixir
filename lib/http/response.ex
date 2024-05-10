defmodule Http.Response do
  defstruct protocol_version: "1.1",
            connection: "Closed",
            content: nil,
            status: nil,
            content_type: "text/plain"

  @protocol "HTTP"
  @separator "\r\n"

  def init do
    %Http.Response{}
  end

  def set_protocol_version(response, version) do
    %Http.Response{response | protocol_version: version}
  end

  def set_connection_type(response, type) when is_binary(type) do
    %Http.Response{response | connection: type}
  end

  def set_content(response, content) do
    %Http.Response{response | content: content}
  end

  def set_status(response, status) do
    %Http.Response{response | status: status}
  end

  def render(response) do
    build_status(response)
    |> append_header("Connection", response.connection)
    |> append_header("Content-Type", response.content_type)
    |> build_content(response)
  end

  defp build_status(response) do
    "#{@protocol}/#{response.protocol_version} #{response.status}"
  end

  defp append_header(response_str, key, value) do
    response_str <> @separator <> "#{key}: #{value}"
  end

  defp append_content(response_str, content) when is_binary(content) do
    response_str <> @separator <> content
  end

  defp append_empty_line(response_str) do
    response_str <> @separator
  end

  defp build_content(response_str, response) when not is_nil(response.content) do
    response_str
    |> append_header("Content-Length", String.length(response.content))
    |> append_empty_line()
    |> append_content(response.content)
  end

  defp build_content(response_str, _response) do
    response_str
  end
end
