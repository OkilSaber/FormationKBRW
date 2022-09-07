defmodule Server.TheFirstPlug do
  import Plug.Conn

  def init(opts) do
    IO.puts("Initializing the first plug")
    opts
  end

  def call(conn, _opts) do
    put_resp_content_type(conn, "application/json")

    case {conn.request_path, conn.method} do
      {"/", "GET"} ->
        send_resp(conn, 200, "Welcome to the new world of Plugs!")

      {"/me", "GET"} ->
        send_resp(conn, 200, "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique.")

      _ ->
        send_resp(conn, 404, "Go away, you are not welcome here.")
    end
  end
end
