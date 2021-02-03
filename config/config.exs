use Mix.Config

config :crawly,
  concurrent_requests_per_domain: 8,
  pipelines: [
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ]
