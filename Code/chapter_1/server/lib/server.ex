defmodule Server do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end
end
