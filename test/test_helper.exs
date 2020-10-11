exclude = Keyword.get(ExUnit.configuration(), :exclude, [])

unless :distributed in exclude do
  AntlUtilsElixir.Cluster.spawn([:"node1@127.0.0.1"])
end

ExUnit.start()
