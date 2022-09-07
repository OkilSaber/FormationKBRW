defmodule TutoKbrwStack do
  use Application

  @impl true
  def start(_type, _args) do
    ServerSupervisor.start_link([])
    {:ok, self()}
  end
end
