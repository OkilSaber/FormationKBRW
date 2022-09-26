defmodule Server.FSMSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Logger.info("Starting FSM Supervisor")
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(order_id) do
    Logger.info("Starting FSM for order #{inspect(order_id)}")

    spec = %{
      id: Server.Payment,
      start: {Server.Payment, :start_link, [order_id]}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end
