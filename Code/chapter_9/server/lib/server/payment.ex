defmodule Server.Payment do
  use GenServer
  require Logger

  def start_link(_, order_id) do
    GenServer.start_link(__MODULE__, order_id, name: order_id, timeout: 300_000)
  end

  @impl true
  def init(order_id) do
    Logger.info("Ça repasse ici")
    {:ok, Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", order_id))}
  end

  @impl true
  def handle_call({action, []}, _from, order) do
    {reply, new_order} = ExFSM.Machine.event(order, {action, []})
    {:reply, reply, new_order}
  end
end
