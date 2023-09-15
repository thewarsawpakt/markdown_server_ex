defmodule MarkdownDirWatcher do
  # transient means the task will always be restarted
  use Task, restart: :transient

  # 60 seconds in ms
  @interval 60 * 1_000

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def process(_) do
  end
end
