defmodule Server.Router do
  use Plug.Router
  require GenServer
  require Logger

  plug(Plug.Static, from: "priv/static", at: "/static")
  plug(:match)
  plug(:dispatch)

  Logger.info("Starting Router")

  get "/api/orders" do
    Logger.info("GET /orders")
    res = GenServer.call(Server.Database, :get_orders)
    send_resp(conn, 200, Poison.encode!(res))
  end

  get "/api/order/:id" do
    Logger.info("GET /order/#{id}")
    [{_, res} | _] = GenServer.call(Server.Database, {:get, id})
    send_resp(conn, 200, Poison.encode!(res))
  end

  get "/api/search/" do
    Logger.info("GET /search/")
    put_resp_content_type(conn, "application/json")
    conn = fetch_query_params(conn)

    [result | _] =
      GenServer.call(
        Server.Database,
        {:search, [{conn.query_params["id"], conn.query_params["value"]}]}
      )

    send_resp(conn, 200, Poison.encode!(result))
  end

  post "/api/create" do
    Logger.info("POST /create")
    {_, res, _} = read_body(conn)
    res = Poison.decode!(res)
    GenServer.cast(Server.Database, {:create, res["id"], res["value"]})
    send_resp(conn, 200, "OK")
  end

  put "/api/update" do
    Logger.info("PUT /update")
    {_, res, _} = read_body(conn)
    res = Poison.decode!(res)
    GenServer.cast(Server.Database, {:update, res["id"], res["value"]})
    send_resp(conn, 200, "OK")
  end

  delete "/api/order/:id" do
    Logger.info("DELETE /order/#{id}")
    :timer.sleep(2000);
    GenServer.cast(Server.Database, {:delete, id})
    send_resp(conn, 204, "")
  end

  get _ do
    IO.puts("Sending HTML file")
    send_file(conn, 200, "priv/static/index.html")
  end

  match _ do
    Logger.error("#{conn.method} #{conn.request_path}")
    send_resp(conn, 404, "Page Not Found")
  end
end
