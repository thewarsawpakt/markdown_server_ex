defmodule MarkdownCache do
  @moduledoc """
  'One could say using a cache for a blog server is akin to putting lipstick on a pig, yet there is beauty in contradiction'

  GenServer-powered cache server. Uses an Agent for storing state.
  """
  require Logger
  use GenServer

  @posts_dir "posts"
  @max_cache_entries 12 # This is a rather arbitrary limit, but it can be changed later.

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec init(any) :: {:ok, %{}}
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:read, filename}, _from, _state) do
    cache = Agent.get(MarkdownCacheAgent, fn cache -> cache end)

    case File.read("#{@posts_dir}/#{filename}") do
      {:ok, contents} ->
        if !Map.has_key?(cache, String.to_atom(filename)) do
          case Earmark.as_html(contents) do
            {:ok, document, _} ->
              if ((Map.to_list(cache) |> length) > @max_cache_entries) do
                # remove LRU entry
                Enum.sort(Map.values(cache), fn a, b ->
                  case Date.compare(a.last_access_time, b.last_access_time) do
                    :lt -> true
                    _ -> false
                  end
                end)
              end
              Agent.update(MarkdownCacheAgent, fn cache ->
                Map.put(cache, String.to_atom(filename), %CacheEntry{
                  last_access_time: DateTime.utc_now(),
                  contents: document
                })
                {:ok, contents}
              end)
            {:error, _, error_messages} ->
              Logger.info("got error(s) whilst transpiling markdown: #{error_messages}]")
            end
        end

        {:reply, contents, %{}}

      {:error, :enoent} ->
        {:reply, :enoent, %{}}
        # TODO: handle other possible errors
    end
  end

  @spec read(String) :: {:reply, :enoent | binary}
  def read(filename) do
    GenServer.call(__MODULE__, {:read, filename})
  end
end
