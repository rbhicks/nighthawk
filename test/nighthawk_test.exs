defmodule NighthawkTest do
  use ExUnit.Case
  doctest Nighthawk

  test "greets the world" do
    assert Nighthawk.hello() == :world
  end
end
