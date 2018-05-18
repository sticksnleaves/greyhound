defmodule Greyhound.BusTest do
  use ExUnit.Case, async: true

  alias Greyhound.{TestBus, TestListener}

  setup tags do
    listener = Module.concat(__MODULE__, "TestListener:#{tags[:line]}")

    start_supervised!(TestBus)
    start_supervised!({TestListener, name: listener, spy: self()})

    {:ok, %{listener: listener}}
  end

  describe "dispatch/2" do
    setup tags do
      :ok = TestListener.subscribe(tags[:listener])

      :ok
    end

    test "handles an event when dispatched" do
      topic = "a_topic"
      message = "a message"

      TestBus.dispatch(topic, message)

      assert_receive {:performed, ^topic, ^message}
    end
  end

  describe "subscribe/1" do
    test "subscribes listener process to a topic", %{listener: listener} do
      pid = Process.whereis(listener)

      :ok = TestListener.subscribe(listener)

      assert pid in TestBus.subscribers("a_topic")
    end
  end

  describe "unsubscribe/1" do
    setup tags do
      :ok = TestListener.subscribe(tags[:listener])

      :ok
    end

    test "unsubscribes listener process from a topic", %{listener: listener} do
      pid = Process.whereis(listener)

      assert pid in TestBus.subscribers("a_topic")

      :ok = TestListener.unsubscribe(listener)

      assert pid not in TestBus.subscribers("a_topic")
    end
  end
end
