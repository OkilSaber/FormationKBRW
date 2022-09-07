defmodule Step05Test do
  use ExUnit.Case
  doctest TutoKbrwStackEx

  test "Create" do
    assert GenServer.cast(Server.Database, {:create, "first", 0}) == :ok
    assert GenServer.cast(Server.Database, {:create, "second", 1}) == :ok
  end

  test "Read" do
    assert GenServer.call(Server.Database, {:read, "first"}) == [{"first", 0}]
  end

  test "Update" do
    assert GenServer.cast(Server.Database, {:update, "first", 2}) == :ok
  end

  test "Delete" do
    assert GenServer.cast(Server.Database, {:delete, "second"}) == :ok
  end
end
