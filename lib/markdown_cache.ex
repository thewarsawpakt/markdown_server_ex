defmodule MarkdownCache do
  @moduledoc """
  'One could say using a cache for a blog server is akin to putting lipstick on a pig, yet there is beauty in contradiction'

  GenServer-powered cache server. Uses an Agent for storing state.
  """
  use GenServer

  @posts_dir "posts"

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  @spec init(any) :: {:error, any} | {:ok, pid}
  def init(_) do
    MarkdownCacheAgent.start_link()
  end

  @spec handle_call({:read, String}) :: {:reply, :enoent | binary}
  def handle_call({:read, filename}) do
    cache = Agent.get(MarkdownCacheAgent, fn cache -> cache end)

    case File.read("#{@posts_dir}/#{filename}") do
      {:ok, contents} ->
        if !cache.has_key?(filename) do
          Agent.update(MarkdownCacheAgent, fn cache ->
            Map.put(cache, filename, %CacheEntry{
              last_access_time: DateTime.utc_now(),
              contents: contents
            })
          end)
        end

        {:reply, contents}

      {:error, :enoent} ->
        {:reply, :enoent}
        # TODO: handle other possible errors
    end
  end

  @spec read(String) :: {:reply, :enoent | binary}
  def read(filename) do
    GenServer.call(__MODULE__, MarkdownCache.handle_call({:read, filename}))
  end
end
