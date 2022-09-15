defmodule Server.Database do
  use GenServer
  require Logger

  def start_link(_opts) do
    Logger.info("Starting Database")
    serv = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    Logger.info("Loading JSON to Database")
    path0 = "/Users/saber/FormationKBRW/Chapters/Resources/chap1/orders_dump/orders_chunk0.json"
    # path1 = "/Users/saber/FormationKBRW/Chapters/Resources/chap1/orders_dump/orders_chunk1.json"
    JsonLoader.load_to_database(Server.Database, path0)
    # JsonLoader.load_to_database(Server.Database, path1)
    serv
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
  def handle_cast({:delete, key}, state) do
        res = :ets.delete(__MODULE__, key)
        IO.inspect(res)
        {:noreply, state}
  end

  @impl true
  def handle_call(:get_orders, _from, state) do
    {:reply, Enum.map(:ets.tab2list(__MODULE__), fn {_, v} -> v end), state}
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
