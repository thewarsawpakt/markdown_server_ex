defmodule MarkdownCacheAgent do
  require Logger
  @doc """
    We use this agent to preserve the cache state in the event of a crash.
  """
  @max_cache_entries 12 # This is a rather arbitrary limit, but it can be changed later.
  use Agent

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  @spec cache({Date, String, binary}) :: :ok
  def cache({last_access_time, filename, contents}) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, filename, %{last_access_time: last_access_time, contents: contents})
    end)
  end


  @doc """
    Adds a thin layer above the internal Map
  """
  @spec has_key(atom()) :: :ok
  def has_key(filename) do
    Logger.debug("request has_key for filename #{filename}")
    Agent.get(__MODULE__, fn state ->
      case Map.fetch(state, String.to_atom(filename)) do
        {:ok, _} -> true
        :error -> false
      end
    end)
  end

  @spec purge :: nil
  def purge() do
  end
end
