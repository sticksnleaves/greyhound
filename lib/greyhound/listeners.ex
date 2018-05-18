defmodule Greyhound.Listeners do
  @moduledoc """
  Registry for tracking listener processes.
  """

  use GenServer

  @ets_opts [
    :duplicate_bag,
    :named_table,
    :public,
    read_concurrency: true,
    write_concurrency: true
  ]

  #
  # client
  #

  @doc """
  Registers a pid to a topic.

  Once registered, a process will be linked and monitored by the registry.
  If a listener process is stopped it will automatically be removed from the
  registry.

  ## Example

      iex> add(MyApp.Bus, "a_topic", self())
      :ok
  """
  @spec add(atom, binary, pid) :: :ok
  def add(server, topic, pid) do
    table = get_table_name(server)

    :ok = GenServer.call(get_name(server), {:monitor, pid})

    true = :ets.insert(table, {topic, pid})

    :ok
  end

  @doc """
  Returns a list of registered pids.

  ## Example

      iex> list(MyApp.Bus, "a_topic")
      [#PID<0.173.0>, #PID<0.174.0>, #PID<0.175.0>]
  """
  @spec list(atom, binary) :: [pid]
  def list(server, topic) do
    Enum.map(:ets.lookup(get_table_name(server), topic), fn {_topic, pid} -> pid end)
  end

  @doc false
  @spec get_name(atom) :: atom
  def get_name(server), do: Module.concat(server, "Listeners")

  @doc """
  Unregisters a process from a topic.

  ## Example

      iex> remove(MyApp.Bus, "a_topic", self())
      :ok
  """
  @spec remove(atom, binary, pid) :: :ok
  def remove(server, topic, pid) do
    table = get_table_name(server)

    true = :ets.match_delete(table, {topic, pid})

    case :ets.select_count(table, [{{:_, pid}, [], [true]}]) do
      0 -> :ok = GenServer.call(get_name(server), {:demonitor, pid})
      _ -> :ok
    end
  end

  @doc false
  @spec start_link(list) :: GenServer.on_start()
  def start_link(opts) do
    name =
      opts
      |> Keyword.get(:server)
      |> Module.concat("Listeners")

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  #
  # callbacks
  #

  @doc false
  def init(opts) do
    :ets.new(get_table_name(opts[:server]), @ets_opts)

    Process.flag(:trap_exit, true)

    {:ok, %{refs: %{}, server: opts[:server]}}
  end

  def handle_call({:demonitor, pid}, _from, %{refs: refs} = state) do
    Process.unlink(pid)
    Process.demonitor(refs[pid])

    new_refs = Map.delete(refs, pid)

    {:reply, :ok, %{state | refs: new_refs}}
  end

  def handle_call({:monitor, pid}, _from, %{refs: refs} = state) do
    Process.link(pid)

    new_refs = Map.put(refs, pid, Process.monitor(pid))

    {:reply, :ok, %{state | refs: new_refs}}
  end

  def handle_info({:DOWN, _ref, _type, pid, _info}, %{server: server} = state) do
    table = get_table_name(server)

    true = :ets.match_delete(table, {:_, pid})

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  #
  # private
  #

  defp get_table_name(server), do: Module.concat(server, "Listeners.Table")
end
