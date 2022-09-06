defmodule Step03Test do
  use ExUnit.Case
  doctest Step03

  test "greets the world" do
    assert Step03.hello() == :world
  end
end
