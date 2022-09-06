defmodule MyGenericServerTest do
  use ExUnit.Case
  doctest MyGenericServer

  test "greets the world" do
    assert MyGenericServer.hello() == :world
  end
end
