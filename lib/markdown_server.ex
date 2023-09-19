defmodule MarkdownServer.Supervisor do
  @moduledoc"""
  Runs a server that serves Markdown files.
  """

  @port 5000 # todo: move this to an env variable
  def start(_, _) do
    children = [
      %{
        id: MarkdownCache,
        start: {MarkdownCache, :start_link, []},
      },
      %{
        id: MarkdownCacheAgent,
        start: {MarkdownCacheAgent, :start_link, []}
      },
      %{
        id: MarkdownWebServer,
        start: {MarkdownWebServer, :accept, [@port]},
      },
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
