defmodule Greyhound.ListenersTest do
  use ExUnit.Case, async: true

  @topic "a_topic"

  defmodule Listener do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: opts[:name])
    end

    def init(opts) do
      send(self(), :init)

      {:ok, Enum.into(opts, %{})}
    end

    def handle_info(:init, %{server: server, spy: spy} = state) do
      if Greyhound.started?(server) do
        :ok = Greyhound.Listeners.add(server, "a_topic", self())

        send(spy, :inited)
      else
        send(self(), :init)
      end

      {:noreply, state}
    end
  end

  setup tags do
    name = Module.concat(__MODULE__, "#{tags[:line]}")

    bus = start_supervised!({Greyhound.Supervisor, middleware: [], otp_app: :test, server: name})

    {:ok, %{bus: bus, server: name}}
  end

  test "add/3 registers a process to a topic", %{server: server} do
    self = self()

    :ok = Greyhound.Listeners.add(server, @topic, self)

    assert self in Greyhound.Listeners.list(server, @topic)
  end

  test "add/3 links the listener process to the registry", %{bus: bus, server: server} do
    name = Module.concat(server, "Listener")

    start_supervised!({Listener, name: name, server: server, spy: self()})

    :ok = Supervisor.stop(bus, :normal)

    :timer.sleep(1)

    assert_receive :inited
    assert Process.whereis(name) in Greyhound.Listeners.list(server, @topic)
  end

  test "remove/3 unregisters a process from a topic", %{server: server} do
    self = self()

    :ok = Greyhound.Listeners.add(server, @topic, self)

    assert self in Greyhound.Listeners.list(server, @topic)

    :ok = Greyhound.Listeners.remove(server, @topic, self)

    assert self not in Greyhound.Listeners.list(server, @topic)
  end

  test "remove/3 unlinks the listener process from the registry", %{bus: bus, server: server} do
    name = Module.concat(server, "Listener")

    pid = start_supervised!({Listener, name: name, server: server, spy: self()})

    assert_receive :inited
    assert pid in Greyhound.Listeners.list(server, @topic)

    :ok = Greyhound.Listeners.remove(server, @topic, pid)

    assert pid not in Greyhound.Listeners.list(server, @topic)

    :ok = Supervisor.stop(bus, :normal)

    refute_receive :inited
  end

  test "when a listener is stopped it is removed from the registry", %{server: server} do
    name = Module.concat(server, "Listener")

    pid =
      start_supervised!({Listener, name: name, server: server, spy: self()}, restart: :temporary)

    assert_receive :inited
    assert pid in Greyhound.Listeners.list(server, @topic)

    :ok = Supervisor.stop(pid, :normal)

    :timer.sleep(1)

    assert pid not in Greyhound.Listeners.list(server, @topic)
  end
end
