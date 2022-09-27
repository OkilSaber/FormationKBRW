defmodule JsonLoader do
  require Logger
  require Task

  def load_to_database(db, path) do
    {:ok, json} = Poison.decode(File.read!(path))

    for item <- json do
      :ets.insert(:"#{db}", {item["id"], item})
    end
  end

  def load_to_riak(path, bucket_name, schema_name, index_name, schema_path) do
    {:ok, json} = Poison.decode(File.read!(path))
    Server.Riak.create_schema(schema_name, schema_path)
    Server.Riak.index_schema(index_name, schema_name)
    Server.Riak.create_bucket(bucket_name, %{"search_index" => index_name})

    Task.async_stream(
      json,
      fn item ->
        Server.Riak.create(
          bucket_name,
          "application/json",
          item["id"],
          item
        )
      end,
      max_concurrency: 10
    ) |> Stream.run()
  end
end
