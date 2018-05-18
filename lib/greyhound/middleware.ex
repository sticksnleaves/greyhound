defmodule Greyhound.Middleware do
  @moduledoc """
  Middleware is reponsible for processing dispatched events.

  All event processing is handled by middleware. This allows Greyhound to
  provide a minimal event bus implementation while providing support for more
  complex event processing workflows.

  See `Greyhound.Middleware.Dispatch.Local` for an example.
  """

  @doc """
  Process an event.

  Receives a `%Greyhound.Event{}` struct as the first argument. The list of
  options provided when the bus was started is passed as the second argument.
  """
  @callback call(event :: Greyhound.Event.t, opts :: list) :: :ok
end
