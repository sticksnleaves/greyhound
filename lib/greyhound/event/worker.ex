defmodule Greyhound.Event.Worker do
  @moduledoc false

  use GenServer, restart: :temporary

  #
  # client
  #

  def start_link(opts, event) do
    new_opts = Keyword.put(opts, :event, event)

    GenServer.start_link(__MODULE__, new_opts)
  end

  #
  # callbacks
  #

  def init(opts) do
    send(self(), :work)

    config =
      opts
      |> Keyword.delete(:event)
      |> Keyword.delete(:middleware)

    {:ok, %{event: opts[:event], middleware: opts[:middleware], config: config}}
  end

  def handle_info(:work, %{event: event, middleware: middleware, config: opts} = state) do
    Enum.each(middleware, fn m -> m.call(event, opts) end)

    {:stop, :normal, state}
  end
end
