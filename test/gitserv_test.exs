defmodule GitservTest do
  use ExUnit.Case
  doctest Gitserv

  test "greets the world" do
    assert Gitserv.hello() == :world
  end
end
