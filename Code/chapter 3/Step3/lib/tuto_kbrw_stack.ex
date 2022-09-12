defmodule TutoKbrwStack do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application")
    ServerSupervisor.start_link([])
    Logger.info("Application Started")
    {:ok, self()}
  end
end
