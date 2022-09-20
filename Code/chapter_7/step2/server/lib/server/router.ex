defmodule Server.Router do
  use Plug.Router
  require GenServer
  require Logger
  require Server.Riak
  require EEx

  Logger.info("Starting Router")

  if Mix.env() == :dev do
    use Plug.Debugger
    plug(WebPack.Plug.Static, at: "/public", from: :tuto_kbrw_stack)
  else
    plug(Plug.Static, at: "/public", from: :tuto_kbrw_stack)
  end

  EEx.function_from_file(:defp, :layout, "web/layout.html.eex", [:render])

  plug(Plug.Static, at: "/public", from: :tuto_kbrw_stack)
  plug(:match)
  plug(:dispatch)

  get "/api/orders" do
    Logger.info("GET /orders")
    conn = fetch_query_params(conn)
    page = conn.query_params["page"] || "0"
    rows = conn.query_params["rows"] || "30"
    sort = conn.query_params["sort"] || "creation_date_index"
    params = Map.delete(conn.query_params, "page")
    params = Map.delete(params, "rows")

    lucene_query =
      if params != %{} do
        Logger.info("Params")

        list =
          Enum.map_every(
            params,
            1,
            fn {key, value} ->
              "#{key}:#{value}"
            end
          )

        Enum.join(list, " AND ")
      else
        Logger.info("No params")
        "*:*"
      end

    response =
      Server.Riak.search(
        "OKIL_ORDERS_index",
        Server.Riak.escape(lucene_query),
        String.to_integer(page) * 30,
        String.to_integer(rows),
        sort <> "+asc"
      )

    map =
      Task.async_stream(
        response["response"]["docs"],
        fn doc ->
          Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", doc["id"]))
        end,
        max_concurrency: 10
      )
      |> Enum.map(fn {:ok, body} -> body end)

    send_resp(conn, 200, Poison.encode!(map))
  end

  get "/api/order/:id" do
    Logger.info("GET /order/#{id}")
    res = Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", id))
    send_resp(conn, 200, Poison.encode!(res))
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
    :timer.sleep(2000)
    # GenServer.cast(Server.Database, {:delete, id})
    Server.Riak.delete_key("OKIL_ORDERS_bucket", id)
    send_resp(conn, 204, "")
  end

  get _ do
    conn = fetch_query_params(conn)

    render =
      Reaxt.render!(
        :app,
        %{path: conn.request_path, cookies: conn.cookies, query: conn.params},
        30_000
      )

    IO.inspect(render)

    send_resp(
      put_resp_header(conn, "content-type", "text/html;charset=utf-8"),
      render.param || 200,
      layout(render)
    )
  end

  match _ do
    Logger.error("#{conn.method} #{conn.request_path}")
    send_resp(conn, 404, "Page Not Found")
  end
end
