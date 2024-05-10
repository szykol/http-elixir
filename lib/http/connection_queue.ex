defmodule Http.ConnectionQueue do
  require Logger
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, []}
  end

  def pop_connection do
    Logger.debug("Popping connection")
    GenServer.call(__MODULE__, :pop_connection, :timer.seconds(1))
  end

  def add_connection(socket) do
    Logger.debug("Adding connection")
    GenServer.call(__MODULE__, {:add_connection, socket}, :timer.seconds(1))
  end

  def handle_call(:pop_connection, _from, [head | tail]) do
    Logger.debug("Handling pop conn")
    {:reply, head, tail}
  end

  def handle_call(:pop_connection, _from, []) do
    Logger.debug("Handling pop conn")
    {:reply, nil, []}
  end

  def handle_call({:add_connection, socket}, _from, list) do
    {:reply, :ok, List.insert_at(list, -1, socket)}
  end
end
