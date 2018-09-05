# Greyhound

## Installation

```elixir
def deps do
  [
    {:greyhound, "~> 0.1.0"}
  ]
end
```

## Define a bus

```elixir
defmodule MyProject.Bus do
  use Greyhound.Bus, otp_app: :my_project
end
```

## Listener

```elixir
defmodule MyProject.MyListener do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    MyProject.Bus.subscribe("a_topic")

    {:ok, state}
  end

  def handle_info({:perform, topic, message}, state) do
    IO.puts topic
    IO.inspect message

    {:noreply, state}
  end
end
```

## Dispatch Event

```elixir
MyProject.Bus.dispatch("a_topic", "a message")

# listener should print "a_topic" and "a message"
```

## Middleware

All dispatching logic is handled by middleware. Middleware can be customized by
overriding the `__middleware__/0` function on a bus. The default middleware
dispatches events sequentially to all listeners on the local node.

https://github.com/sticksnleaves/greyhound/blob/master/lib/greyhound/middleware/dispatch/local.ex
