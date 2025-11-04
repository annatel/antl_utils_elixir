import Config

config :logger, :console,
  format: "$metadata$message\n",
  metadata: [:api_name, :api_request_id]
