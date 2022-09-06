defmodule Step02Test do
  use ExUnit.Case
  doctest Step02

  test "greets the world" do
    assert Step02.hello() == :world
  end
end
