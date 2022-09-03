defmodule Chapter0Test do
  use ExUnit.Case
  doctest Chapter0

  test "greets the world" do
    assert Chapter0.hello() == :world
  end
end
