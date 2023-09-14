defmodule MarkdownCache do
  @moduledoc """
  "One could say caching for a blog server is akin to putting lipstick on a pig, yet there is beauty in contradiction"

  GenServer-powered cache server. uses an Agent for storing state
  """
  use GenServer

  @posts_dir "posts"

  def init(_) do
    {:ok, }
  end

  def handle_call({:read, filename}, _from, state) do
    # If the file is not found, bubble up the exception such that the caller can return a 404
    # TODO: use Registry to communicate with cache agent
    {:ok, binary} = File.read("#{@posts_dir}/#{filename}")
    if !state.has_key?(filename) do
      state.put(%{last_access_time: DateTime.utc_now(), filename: filename, contents: binary})
    end
    {:reply, binary}
  end


end