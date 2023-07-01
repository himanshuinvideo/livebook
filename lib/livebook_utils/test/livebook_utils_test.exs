defmodule LivebookUtilsTest do
  use ExUnit.Case
  doctest LivebookUtils

  test "greets the world" do
    assert LivebookUtils.hello() == :world
  end
end
