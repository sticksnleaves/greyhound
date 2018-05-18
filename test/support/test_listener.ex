defmodule Greyhound.TestListener do
  use GenServer

  alias Greyhound.{TestBus}

  def start_link(opts) do
    bus = Keyword.get(opts, :bus, TestBus)

    state = Keyword.put(opts, :bus, bus)

    GenServer.start_link(__MODULE__, state, name: opts[:name])
  end

  def subscribe(server), do: GenServer.call(server, :subscribe)

  def unsubscribe(server), do: GenServer.call(server, :unsubscribe)

  def init(opts), do: {:ok, Enum.into(opts, %{})}

  def handle_call(:subscribe, _from, %{bus: bus} = state) do
    bus.subscribe("a_topic")

    {:reply, :ok, state}
  end

  def handle_call(:unsubscribe, _from, %{bus: bus} = state) do
    bus.unsubscribe("a_topic")

    {:reply, :ok, state}
  end

  def handle_info({:perform, topic, message}, %{spy: spy} = state) do
    send(spy, {:performed, topic, message})

    {:noreply, state}
  end
end
