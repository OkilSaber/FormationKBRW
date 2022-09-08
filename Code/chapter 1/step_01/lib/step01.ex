defmodule Step01 do
  use GenServer

  def start_link(opts) do
    table_name = Keyword.fetch!(opts, :name)

    Tuple.insert_at(
      GenServer.start_link(__MODULE__, []),
      2,
      :ets.new(table_name, [:named_table, read_concurrency: true])
    )
  end

  @impl true
  def init(server) do
    {:ok, server}
  end

  def cast(_server, {request, table, name}) do
    case request do
      :create ->
        :ets.insert(table, {name, name})
        {:noreply, name}

      :delete ->
        :ets.delete(table, name)
        {:noreply, name}
    end
  end

  def call(_server, {request, table, name}) do
    case request do
      :read ->
        case :ets.lookup(table, name) do
          [{_, value}] -> {:reply, value, name}
          [] -> {:reply, nil, name}
        end
    end
  end

end
# {:ok, server, table} = Step02.start_link([name: :table])
# Step02.cast(server, {:create, table, "test"})
# Step02.call(server, {:read, table, "test"})
