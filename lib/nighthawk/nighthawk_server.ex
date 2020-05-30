defmodule Nighthawk.NighthawkServer do
  use GenServer


  #
  # GenServer Callbacks
  #

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    IO.puts "±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±"
    {:ok, {}}
  end
end
