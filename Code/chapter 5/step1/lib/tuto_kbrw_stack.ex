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
    Logger.info("Application Started")

    schema = "/Users/saber/FormationKBRW/Code/chapter 5/step1/lib/schemas/order_schema.xml"
    # sample_json = "/Users/saber/FormationKBRW/Code/chapter 5/step1/lib/schemas/sample.json"
    path0 = "/Users/saber/FormationKBRW/Chapters/Resources/chap1/orders_dump/orders_chunk0.json"
    Server.Riak.empty_bucket("OKIL_ORDERS_bucket")

    JsonLoader.load_to_riak(
      path0,
      "OKIL_ORDERS_bucket",
      "OKIL_ORDERS_schema",
      "OKIL_ORDERS_index",
      schema
    )

    Server.Riak.get_bucket_keys("OKIL_ORDERS_bucket")

    {:ok, self()}
  end
end

# Server.Riak.create_schema("SABER_ORDERS_schema", "./lib/schemas/order_schema.xml")
# Server.Riak.index_schema("SABER_ORDERS_index", "SABER_ORDERS_schema")
# Server.Riak.create_bucket("SABER_ORDERS_bucket", %{"search_index" => "SABER_ORDERS_index"})
# Server.Riak.get_bucket_keys("SABER_ORDERS_bucket")
# s = rand_str(10)
# Server.Riak.create(
#   "SABER_ORDERS_bucket",
#   "application/json",
#   s,
#   %{
#     "creation" => %{
#       "date" => %{
#         "int" => :os.system_time(),
#         "index" => NaiveDateTime.utc_now()
#       }
#     },
#     "custom" => %{
#       "shipping_method" => "delivery",
#       "customer" => %{
#         "last_name" => "lakhdari",
#         "full_name" => "saber lakhdari",
#         "email" => "okil.lakhdari@kbrwadventure.com"
#       }
#     },
#     "type" => "order",
#     "id" => s
#   }
# )
# Server.Riak.get_bucket_keys("SABER_ORDERS_bucket")
# Server.Riak.get_key_data("SABER_ORDERS_bucket", s)
# Server.Riak.empty_bucket("SABER_ORDERS_bucket")
# Server.Riak.get_bucket_keys("SABER_ORDERS_bucket")
# Server.Riak.delete_bucket("SABER_ORDERS_bucket")
# Server.Riak.get_bucket_keys("SABER_ORDERS_bucket")
