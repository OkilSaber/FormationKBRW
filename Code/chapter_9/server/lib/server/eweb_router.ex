defmodule Server.EwebRouter do
  use Ewebmachine.Builder.Resources
  require EEx
  require Logger
  if Mix.env() == :dev, do: plug(Ewebmachine.Plug.Debug)
  plug(:resource_match)
  plug(Ewebmachine.Plug.Run)
  plug(Ewebmachine.Plug.Send)

  resource "/api/orders" do
    %{}
  after
    allowed_methods(do: ["GET"])
    content_types_provided(do: ["application/json": :to_json])

    defh to_json(conn, state) do
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
          String.to_integer(page) * String.to_integer(rows),
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

      {Poison.encode!(map), conn, state}
    end
  end

  resource "/ping" do
    %{}
  after
    allowed_methods(do: ["GET"])
    content_types_provided(do: ["text/plain": :pong])

    defh pong(conn, state) do
      Logger.info("GET /ping")
      {"pong", conn, state}
    end
  end

  resource "/api/order/:id" do
    %{id: id}
  after
    allowed_methods(do: ["GET", "DELETE"])
    content_types_provided(do: ["application/json": :to_json])

    defh to_json(conn, state) do
      Logger.info("GET /order/#{state.id}")
      res = Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", state.id))
      {Poison.encode!(res), conn, state}
    end

    defh delete_resource(conn, state) do
      Logger.info("DELETE /order/#{state.id}")
      :timer.sleep(1000)
      Server.Riak.delete_key("OKIL_ORDERS_bucket", state.id)
      {true, conn, state}
    end
  end

  resource "/api/create" do
    %{}
  after
    allowed_methods(do: ["POST"])
    content_types_provided(do: ["application/json": :to_json])

    defh to_json(conn, state) do
      Logger.info("POST /create")
      {_, res, _} = read_body(conn)
      res = Poison.decode!(res)
      GenServer.cast(Server.Database, {:create, res["id"], res["value"]})
      {"OK", conn, state}
    end
  end

  resource "/api/update/:id" do
    %{id: id}
  after
    allowed_methods(do: ["PUT"])
    content_types_accepted(do: ["application/json": :from_json])

    process_post do
      from_json(conn, state)
    end

    defh from_json(conn, state) do
      Logger.info("PUT /update")
      {_, res, _} = read_body(conn)
      res = Poison.decode!(res)
      Server.Riak.update_key("OKIL_ORDERS_bucket", state.id, res)

      {true,
       %{
         conn
         | resp_body:
             Poison.encode!(
               Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", state.id))
             )
       }, state}
    end
  end

  resource "/api/pay/:id" do
    %{id: id}
  after
    allowed_methods(do: ["POST"])
    content_types_provided(do: ["application/json": :to_json])

    process_post do
      {_, pid} = Server.FSMSupervisor.start_child(String.to_atom(state.id))
      order = Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", state.id))

      case order["status"]["state"] do
        "init" ->
          GenServer.call(pid, {:process_payment, []})
        "not_verified" ->
          GenServer.call(pid, {:verfication, []})
      end

      {true,
       %{
         conn
         | resp_body:
             Poison.encode!(
               Poison.decode!(Server.Riak.get_key_data("OKIL_ORDERS_bucket", state.id))
             )
       }, state}
    end
  end

  resource "/*_" do
    %{}
  after
    EEx.function_from_file(:defp, :layout, "web/layout.html.eex", [:render])

    if Mix.env() == :dev do
      use Plug.Debugger
      plug(WebPack.Plug.Static, at: "/public", from: :tuto_kbrw_stack)
    else
      plug(Plug.Static, at: "/public", from: :tuto_kbrw_stack)
    end

    content_types_provided(do: ["text/html": :to_content])

    defh to_content(conn, state) do
      render =
        Reaxt.render!(
          :app,
          %{path: conn.request_path, cookies: conn.cookies, query: conn.params},
          30_000
        )

      {layout(render), conn, state}
    end
  end
end
