defmodule MarkdownServer do
  @moduledoc """
  Runs a server that serves Markdown files.
  """

  def init(_) do
    children = [
      MarkdownCache,
      MarkdownCacheAgent
    ]
    {:ok, _} = Supervisor.init(children, strategy: :one_for_one)
  end
end
