defmodule Mix.Tasks.Antl.Earthly.Docker do
  @moduledoc "Build docker image via earthly, tagged with current version of the application"
  @shortdoc "Build docker image via earthly"

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.shell().cmd("earthly --build-arg TAG=#{version()} +docker")
  end

  defp version() do
    Mix.Project.config()[:version]
  end
end
