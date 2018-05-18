defmodule Greyhound.Bus do
  defmacro __using__(opts) do
    quote do
      @otp_app Keyword.fetch!(unquote(opts), :otp_app)

      @application_config Application.get_env(@otp_app, __MODULE__, [])
      
      @name Keyword.get(unquote(opts), :name, __MODULE__)

      @spec start_link(Keyword.t()) :: Supervisor.on_start()
      def start_link(opts) do
        config =
          @application_config
          |> Keyword.merge(opts)
          |> Keyword.put(:middleware, __middleware__())
          |> Keyword.put(:otp_app, @otp_app)
          |> Keyword.put(:server, @name)

        Greyhound.Supervisor.start_link(config)
      end

      @doc """
      Emits an event for processing.

      Events are processed using middleware. See `Greyhound.Middleware` for more
      details.

      ## Example

          iex> #{__MODULE__}.dispatch("a_topic", "a message")
          :ok
      """
      @spec dispatch(binary, term) :: :ok | {:error, :not_started}
      def dispatch(topic, message), do: Greyhound.dispatch(@name, topic, message)

      @doc """
      Subscribes the current process to a topic.

      ## Example

          iex> #{__MODULE__}.subscribe("a_topic")
          :ok
      """
      @spec subscribe(binary) :: :ok | {:error, :not_started}
      def subscribe(topic), do: Greyhound.subscribe(@name, topic, self())

      @doc """
      Returns a list of processes subscribed to a topic.

      ## Example

          iex> #{__MODULE__}.subscribers("a topic")
          [#PID<0.173.0>, #PID<0.174.0>, #PID<0.175.0>]
      """
      @spec subscribers(binary) :: :ok | {:error, :not_started}
      def subscribers(topic), do: Greyhound.subscribers(@name, topic)

      @doc """
      Unsubscribes the current process from a topic.

      ## Example

          iex> #{__MODULE__}.unsubscribe("a_topic")
          :ok
      """
      @spec unsubscribe(binary) :: :ok | {:error, :not_started}
      def unsubscribe(topic), do: Greyhound.unsubscribe(@name, topic, self())

      @doc """
      Returns a list of middleware modules that implement the
      `Greyhound.Middleware` callbacks.

      Override this function if a different set of middleware is required.
      """
      @spec __middleware__ :: [module]
      def __middleware__(), do: [Greyhound.Middleware.Dispatch.Local]

      defoverridable __middleware__: 0
    end
  end
end
