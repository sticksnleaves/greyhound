defmodule Greyhound.Middleware.Dispatch.Local do
  @moduledoc """
  Dispatches events on the local node.

  When called, this middleware will look up all listeners for the dispatched
  topic and send `{:perform, topic, message}` sequentially to each listener.

  This is the default middleware provided by `Greyhound.Bus`.
  """

  @behaviour Greyhound.Middleware

  def call(%Greyhound.Event{message: message, topic: topic}, opts) do
    server = opts[:server]

    subscribers = Greyhound.subscribers(server, topic)

    Enum.each(subscribers, fn pid -> send(pid, {:perform, topic, message}) end)

    :ok
  end
end
