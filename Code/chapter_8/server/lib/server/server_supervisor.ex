defmodule ServerSupervisor do
  use Supervisor
  require Logger
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      # {Server.Database, name: Server.Database},
      # {Server.FSMSupervisor, name: Server.FSMSupervisor},
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]}
    ]

    Logger.info("Starting Children")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
