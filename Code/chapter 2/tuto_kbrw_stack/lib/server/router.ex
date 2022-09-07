defmodule Server.Router do
  use Server.TheCreator

  my_get "/" do
    {200, "Hello /"}
  end

  my_get "/me" do
    {200, "Hello /me"}
  end

  my_error code: 404, content: "Custom error message"
end
