defmodule Server.TheCreator do
  defmacro __using__(_opts) do
    quote do
      import Plug.Conn
      import Server.TheCreator
      @before_compile Server.TheCreator
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @behaviour Plug

      @impl Plug
      def init(opts) do
        opts
      end

      @impl Plug
      def call(conn, _opts) do
        put_resp_content_type(conn, "application/json")
        pattern_matcher(conn, conn.request_path)
      end
    end
  end

  defmacro my_get(path, do: response) do
    quote do
      def pattern_matcher(conn, unquote(path)) do
        {code, message} = unquote(response)
        send_resp(conn, code, message)
      end
    end
  end

  defmacro my_error(code: code, content: content) do
    quote do
      def pattern_matcher(conn, _path) do
        send_resp(conn, unquote(code), unquote(content))
      end
    end
  end
end
