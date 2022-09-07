defmodule Step05Test do
  use ExUnit.Case
  doctest TutoKbrwStackEx

  test "Create" do
    assert GenServer.cast(Server.Database, {:create, "first", 0}) == :ok
    assert GenServer.cast(Server.Database, {:create, "second", 1}) == :ok
  end

  test "Read" do
    assert GenServer.call(Server.Database, {:get, "first"}) == [{"first", 0}]
  end

  test "Update" do
    assert GenServer.cast(Server.Database, {:update, "first", 2}) == :ok
  end

  test "Delete" do
    assert GenServer.cast(Server.Database, {:delete, "second"}) == :ok
    assert GenServer.cast(Server.Database, {:delete, "first"}) == :ok
  end

  test "Load database from JSON" do
    path = "/Users/saber/FormationKBRW/Chapters/Resources/chap1/orders_dump/orders_chunk0.json"
    {:ok, json} = Poison.decode(File.read!(path))

    [obj | _] = json
    JsonLoader.load_to_database(Server.Database, path)

    assert GenServer.call(Server.Database, {:get, "nat_order000147815"}) == [
             {"nat_order000147815", obj}
           ]
  end

  test "Search database" do
    path = "/Users/saber/FormationKBRW/Chapters/Resources/chap1/orders_dump/orders_chunk0.json"
    {:ok, json} = Poison.decode(File.read!(path))

    [first | rest] = json
    [second | _] = rest

    assert GenServer.call(
             Server.Database,
             {:search, [{"id", "nat_order000147815"}, {"id", "nat_order000147814"}]}
           ) == [first, second]
  end
end
