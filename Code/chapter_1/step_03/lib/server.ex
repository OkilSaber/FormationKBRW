defmodule Server do
  use GenServer

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, :ok}
  end

  def call(server, message) do
    GenServer.call(server, message)
  end

  def cast(server, message) do
    GenServer.cast(server, message)
  end

  @impl true
  def handle_call(object, _from, intern_state) do
    IO.puts("Received call with #{inspect(object)}")
    {:reply, object, intern_state}
  end

  @impl true
  def handle_cast(object, intern_state) do
    IO.puts("Received cast with #{inspect(object)}")
    {:noreply, intern_state}
  end
end
