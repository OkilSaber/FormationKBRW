defmodule TutoKbrwStack do
  use Application
  require Logger
  require Server.Riak

  def rand_str(len) do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789abcdef')>>
  end

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application")
    ServerSupervisor.start_link([])

    Application.put_env(
      :reaxt,
      :global_config,
      Map.merge(
        Application.get_env(:reaxt, :global_config),
        %{localhost: "http://localhost:4001"}
      )
    )

    Reaxt.reload()
    Logger.info("Application Started")
    {:ok, self()}
  end

  def initialize_commands(bucket) do
    Task.async_stream(
      Server.Riak.get_bucket_keys(bucket),
      fn key ->
        data = Poison.decode!(Server.Riak.get_key_data(bucket, key))
        data =
          Map.update!(data, "status", fn status ->
            Map.update!(status, "state", fn _state ->
              "init"
            end)
          end)

        Server.Riak.update_key(bucket, data["id"], data)
      end,
      max_concurrency: 10,
      ordered: false
    ) |> Stream.run()
  end
end
