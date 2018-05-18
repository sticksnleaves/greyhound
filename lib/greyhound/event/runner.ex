defmodule Greyhound.Event.Runner do
  @moduledoc false

  use DynamicSupervisor

  #
  # client
  #

  @spec get_name(atom) :: atom
  def get_name(server), do: Module.concat(server, "Event.Runner")

  @spec run(atom, Greyhound.Event.t) :: :ok
  def run(server, event) do
    {:ok, _pid} = DynamicSupervisor.start_child(get_name(server), {Greyhound.Event.Worker, event})

    :ok
  end

  @spec start_link(list) :: Supervisor.on_start()
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: get_name(opts[:server]))
  end

  #
  # callbacks
  #

  def init(opts) do
    DynamicSupervisor.init(extra_arguments: [opts], strategy: :one_for_one)
  end
end
