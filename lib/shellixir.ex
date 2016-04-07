defmodule Shellixir do
  def ls_bin do
    {:ok, binaries} = File.ls("/bin")
    binaries
  end

  def run_bin(binary, args) do
    port = Port.open(
      {:spawn, "#{binary} #{args}"},
      [:stderr_to_stdout])

    receive do
      {^port, {:data, output}} -> output |> List.to_string |> String.split
    end
  end

  def run_bin(binary, args, [line_split: false]) do
    port = Port.open(
      {:spawn, "#{binary} #{args}"},
      [:stderr_to_stdout])

    receive do
      {^port, {:data, output}} -> output |> List.to_string
    end
  end

  @binaries (File.ls!("/bin/") |> Enum.map(&String.to_atom/1))

  for binary <- @binaries do
    defmacro unquote(binary)(args) do
      run_bin(unquote(binary), args)
    end

    defmacro unquote(binary)(args, opts) do
      run_bin(unquote(binary), args, opts)
    end
  end
end
