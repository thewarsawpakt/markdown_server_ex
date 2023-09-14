defmodule MarkdownCacheAgent do
  @doc """
    We use this agent to preserve the cache state in the event of a crash.
  """
  use Agent



  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def cache({last_access_time, filename, contents}) do
    Agent.update(__MODULE__, fn state -> Map.put(state, filename, %{last_access_time: last_access_time, contents: contents}) end)
  end

  def purge() do
  end
end
