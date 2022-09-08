defmodule MyGenericServer do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def loop({callback_module, server_state}) do
    receive do
      {:call, from, request} ->
        {_, new_server_state} = callback_module.handle_call(request, server_state)
        send(from, new_server_state)
        loop({callback_module, new_server_state})
      {:cast, request} ->
        new_server_state = callback_module.handle_cast(request, server_state)
        loop({callback_module, new_server_state})
    end

    loop({callback_module, server_state})
  end

  def cast(process_pid, request) do
    Kernel.send(process_pid, {:cast, request})
  end

  def call(process_pid, request) do
    Kernel.send(process_pid, {:call, self(), request})
    receive do
      value ->
        value
    end

  end

  def start_link(callack_module, server_initial_state) do
    {:ok,
     spawn_link(fn ->
       loop({callack_module, server_initial_state})
     end)}
  end
end
