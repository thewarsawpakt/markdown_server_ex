defmodule MarkdownDirWatcher do
  # transient means the task will always be restarted
  use Task, restart: :transient

  @interval 60 * 1_000 # 60 seconds

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def process(_) do
  end


end
