defmodule Greyhound.Supervisor do
  @moduledoc """
  Primary supervisor used to start a bus.

  This module will most likely not be used directly. The `Greyhound.Bus` macro
  is responsible for starting this supervisor. However, in instances where you
  would like to use a bus without the help of `Greyhound.Bus` you can manually
  add this supervisor to your superivision tree

  ## Required Options

  * `:middleware` - a list of middleware modules used to process dispatched
                    events
  * `:otp_app` - an atom of the OTP app this bus belongs to. This is primarily
                 used for grabbing values from the application config.
                 (e.g. `:my_app`)
  * `:server` - an atom used to identify a bus. This value is used to send
                messages to a specific bus. If you would like to run multiple
                busses simultaneously make sure this value is different for each
                supervisor. (e.g. `MyApp.Bus`)

  See `Greyhound` for details on using a bus directly.
  """

  use Supervisor

  #
  # client
  #

  @doc "Starts a bus and links it to the current process."
  @spec start_link(list) :: Supervisor.on_start()
  def start_link(opts) do
    verify_opts!(opts)

    Supervisor.start_link(__MODULE__, opts, name: opts[:server])
  end

  #
  # callbacks
  #

  @doc false
  def init(opts), do: Supervisor.init(children(opts), strategy: :one_for_one)

  #
  # private
  #

  defp children(opts) do
    [
      {Greyhound.Listeners, opts},
      {Greyhound.Event.Runner, opts}
    ]
  end

  defp verify_opts!(opts) do
    Keyword.fetch!(opts, :otp_app)
    Keyword.fetch!(opts, :server)
    Keyword.fetch!(opts, :middleware)
  end
end
