defmodule TutoKbrwStack do
  use Application
  require Logger
  require Server.Riak
  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application")
    ServerSupervisor.start_link([])
    Logger.info("Application Started")
    Server.Riak.get_schema("SABER_ORDERS_schema")
    Server.Riak.create_bucket("SABER_ORDERS_bucket", %{search_index: "SABER_ORDERS_index"})
    {:ok, self()}
  end
end
