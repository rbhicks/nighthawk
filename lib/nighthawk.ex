defmodule Nighthawk do
  def start_link(type, args) do
    Nighthawk.Application.start(type, args)
  end
end
