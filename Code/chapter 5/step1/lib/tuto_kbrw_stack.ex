defmodule TutoKbrwStack do
  use Application
  require Logger
  require Server.Riak
  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application")
    ServerSupervisor.start_link([])
    Logger.info("Application Started")
    Logger.info("Requesting Riak")
    {:ok, self()}
  end
end
