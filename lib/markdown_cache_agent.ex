defmodule MarkdownCacheAgent do
  @doc """
    We use this agent to preserve the cache state in the event of a crash.
  """
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

  @spec purge :: nil
  def purge() do
  end
end
