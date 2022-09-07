defmodule Server.Database do
  use GenServer

  def start_link(_opts) do
    IO.puts("Starting database")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    :ets.new(__MODULE__, [:public, :named_table, read_concurrency: true])
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
  def handle_call({:get, key}, _from, state) do
    {:reply, :ets.lookup(__MODULE__, key), state}
  end

  def handle_call({:search, criterias}, _from, state) do
    {:reply, search(__MODULE__, criterias), state}
  end

  def search(database, criterias) do
    Enum.map(criterias, fn criteria ->
      [{_, res} | _] = :ets.match_object(database, {:"$1", Map.new([criteria])})
      res
    end)
  end
end
