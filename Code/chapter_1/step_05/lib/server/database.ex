defmodule Server.Database do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    {:ok, state}
  end

  @impl true
  def handle_cast({request, key, value}, state) do
    case request do
      :create ->
        :ets.insert(__MODULE__, {key, value})
        {:noreply, state}

      :update ->
        :ets.insert(__MODULE__, {key, value})
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({request, key}, state) do
    case request do
      :delete ->
        :ets.delete(__MODULE__, key)
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:read, key}, _from, state) do
    {:reply, :ets.lookup(__MODULE__, key), state}
  end

  def search(database, criteria) do
    results = []
    for item <- criteria do
      IO.puts("Searching #{item}")
      results = results ++ :ets.lookup(database, item)
    end
    results
  end
end
