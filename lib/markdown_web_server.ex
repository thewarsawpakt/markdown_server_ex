defmodule MarkdownWebServer do
  @moduledoc """
  Simple HTTP Server acting as a bridge between clients and backend processes
  """
  require Logger

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 1024) do
      {:ok, data} ->
        IO.puts(data)
        :gen_tcp.send(socket, data)
        serve(socket)
      {:error, error} -> IO.puts(error)
    end
  end

  defp loop_acceptor(socket) do
      {:ok, client} = :gen_tcp.accept(socket)
      case Task.Supervisor.start_child(MarkdownServer.Supervisor, fn -> serve(client) end) do
        {:ok, pid} ->
          :ok = :gen_tcp.controlling_process(client, pid)
          loop_acceptor(socket)
        {:error, e} -> IO.puts("got #{e} when trying to start a child for socket #{socket}")
      end

    end
end
