defmodule ServerSupervisor do
  use Supervisor

  def start_link(opts) do
    IO.puts("Starting server supervisor")
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    IO.puts("Initializing server supervisor")
    children = [
      {Server.Database, name: Server.Database},
      {Plug.Cowboy, scheme: :http, plug: Server.TheFirstPlug, options: [port: 4040]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
