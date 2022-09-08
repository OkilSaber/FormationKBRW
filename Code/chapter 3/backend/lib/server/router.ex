defmodule Server.Router do
  use Plug.Router
  require GenServer
  require Logger

  plug(:match)
  plug(:dispatch)
  Logger.info("Starting Router")

  get "/" do
    Logger.info("GET /")
    send_resp(conn, 200, "Elixir Server")
  end

  get "/get" do
    Logger.info("GET /get")
    conn = fetch_query_params(conn)
    [{_, res} | _] = GenServer.call(Server.Database, {:get, conn.query_params["id"]})
    send_resp(conn, 200, Poison.encode!(res))
  end

  get "/search/" do
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

  post "/create" do
    Logger.info("POST /create")
    {_, res, _} = read_body(conn)
    res = Poison.decode!(res)
    GenServer.cast(Server.Database, {:create, res["id"], res["value"]})
    send_resp(conn, 200, "OK")
  end

  put "/update" do
    Logger.info("PUT /update")
    {_, res, _} = read_body(conn)
    res = Poison.decode!(res)
    GenServer.cast(Server.Database, {:update, res["id"], res["value"]})
    send_resp(conn, 200, "OK")
  end

  delete "/delete" do
    Logger.info("DELETE /delete")
    {_, res, _} = read_body(conn)
    res = Poison.decode!(res)
    GenServer.cast(Server.Database, {:delete, res["id"]})
    send_resp(conn, 200, "OK")
  end

  match _ do
    Logger.error("#{conn.method} #{conn.request_path}")
    send_resp(conn, 404, "Page Not Found")
  end
end
