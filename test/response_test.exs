defmodule Http.Response.Test do
  use ExUnit.Case
  doctest Http

  @separator "\r\n"

  test "basic rendering http response" do
    response =
      Http.Response.init()
      |> Http.Response.set_status("200 OK")
      |> Http.Response.set_content("dupajasia")

    expected_response = """
    HTTP/1.1 200 OK\r\n\
    Connection: Closed\r\n\
    Content-Type: text/plain\r\n\
    Content-Length: 9\r\n\
    \r\n\
    dupajasia\
    """

    assert expected_response == Http.Response.render(response)
  end

  test "rendering http response with conn type" do
    response =
      Http.Response.init()
      |> Http.Response.set_status("200 OK")
      |> Http.Response.set_content("dupajasia")
      |> Http.Response.set_connection_type("other")

    expected_response = """
    HTTP/1.1 200 OK\r\n\
    Connection: other\r\n\
    Content-Type: text/plain\r\n\
    Content-Length: 9\r\n\
    \r\n\
    dupajasia\
    """

    assert expected_response == Http.Response.render(response)
  end

  test "rendering http response with status" do
    response =
      Http.Response.init()
      |> Http.Response.set_status("404 Not Found")
      |> Http.Response.set_content("dupajasia")

    expected_response = """
    HTTP/1.1 404 Not Found\r\n\
    Connection: Closed\r\n\
    Content-Type: text/plain\r\n\
    Content-Length: 9\r\n\
    \r\n\
    dupajasia\
    """

    assert expected_response == Http.Response.render(response)
  end

  test "rendering http response with protocol version" do
    response =
      Http.Response.init()
      |> Http.Response.set_status("200 OK")
      |> Http.Response.set_content("dupajasia")
      |> Http.Response.set_protocol_version("3.0")

    expected_response = """
    HTTP/3.0 200 OK\r\n\
    Connection: Closed\r\n\
    Content-Type: text/plain\r\n\
    Content-Length: 9\r\n\
    \r\n\
    dupajasia\
    """

    assert expected_response == Http.Response.render(response)
  end

  test "rendering http response with no content" do
    response =
      Http.Response.init()
      |> Http.Response.set_status("200 OK")

    expected_response = """
    HTTP/1.1 200 OK\r\n\
    Connection: Closed\r\n\
    Content-Type: text/plain\
    """

    assert expected_response == Http.Response.render(response)
  end
end
