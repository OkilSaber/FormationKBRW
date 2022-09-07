defmodule TutoKbrwStack do
  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Starting TutoKbrwStack")
    ServerSupervisor.start_link([])
    {:ok, self()}
  end
end
