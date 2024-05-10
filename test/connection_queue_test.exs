defmodule HttpTest do
  use ExUnit.Case
  doctest Http

  test "connection queue works" do
    :ok = Http.ConnectionQueue.add_connection(:mock_socket)
    :ok = Http.ConnectionQueue.add_connection(:second_socket)

    :mock_socket = Http.ConnectionQueue.pop_connection()
    :second_socket = Http.ConnectionQueue.pop_connection()
  end
end
