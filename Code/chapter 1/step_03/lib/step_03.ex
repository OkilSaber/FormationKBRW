defmodule Step03 do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Server, name: Server}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# {:ok, sup} = Step03.start_link([])
# [{_, server, _, _}] = Supervisor.which_children(sup)
# GenServer.call(server, :hello)
# Step03.call(Server, :hello)
