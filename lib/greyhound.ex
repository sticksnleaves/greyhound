defmodule Greyhound do
  @doc """
  Emits an event for processing.

  Events are processed using middleware. See `Greyhound.Middleware` for more
  details.

  ## Example

      iex> Greyhound.dispatch(MyApp.Bus, "a_topic", "a message")
      :ok
  """
  @spec dispatch(atom, binary, term) :: :ok | {:error, :not_started}
  def dispatch(server, topic, message) do
    case started?(server) do
      true -> do_dispatch(server, topic, message)
      false -> {:error, :not_started}
    end
  end

  defp do_dispatch(server, topic, message) do
    event = Greyhound.Event.new(topic, message)

    Greyhound.Event.Runner.run(server, event)
  end

  @doc false
  @spec started?(atom) :: boolean
  def started?(server) do
    !!Process.whereis(server) &&
    !!Process.whereis(Greyhound.Listeners.get_name(server))
    !!Process.whereis(Greyhound.Event.Runner.get_name(server))
  end

  @doc """
  Subscribe a listener to a topic.

  ## Example

      iex> subscribe(MyApp.Bus, "a_topic", self())
      :ok
  """
  @spec subscribe(atom, binary, pid) :: :ok | {:error, :not_started}
  def subscribe(server, topic, pid) do
    case started?(server) do
      true -> Greyhound.Listeners.add(server, topic, pid)
      false -> {:error, :not_started}
    end
  end

  @doc """
  Returns a list of processes subscribed to a topic.

  ## Example

      iex> subscribers(MyApp.Bus, "a_topic")
      [#PID<0.173.0>, #PID<0.174.0>, #PID<0.175.0>]
  """
  @spec subscribers(atom, binary) :: [pid] | {:error, :not_started}
  def subscribers(server, topic) do
    case started?(server) do
      true -> Greyhound.Listeners.list(server, topic)
      false -> {:error, :not_started}
    end
  end

  @doc """
  Unsubscribe a listener from a topic.

  ## Example

      iex> unsubscribe(MyApp.Bus, "a_topic", self())
      :ok
  """
  @spec unsubscribe(atom, binary, pid) :: :ok | {:error, :not_started}
  def unsubscribe(server, topic, pid) do
    case started?(server) do
      true -> Greyhound.Listeners.remove(server, topic, pid)
      false -> {:error, :not_started}
    end
  end
end
