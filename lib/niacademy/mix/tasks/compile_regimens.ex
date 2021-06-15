defmodule Mix.Tasks.CompileRegimens do
  use Mix.Task

  @shortdoc "Compiles regimen description file."
  def run(_) do
    input_path = "lib/regimens.dhall"
    output_path = "lib/regimens.yml"

    case System.cmd("dhall-to-yaml", ["--file", input_path, "--output", output_path]) do
      {_, 0} -> IO.puts("Wrote #{output_path}.")
      {err, _} -> raise "Error running dhall-to-yaml:\n #{err}"
    end
  end
end
