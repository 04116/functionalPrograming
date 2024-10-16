defmodule StudentRoll.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StudentRollWeb.Telemetry,
      StudentRoll.Repo,
      {DNSCluster, query: Application.get_env(:student_roll, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StudentRoll.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StudentRoll.Finch},
      # Start a worker by calling: StudentRoll.Worker.start_link(arg)
      # {StudentRoll.Worker, arg},
      # Start to serve requests, typically the last entry
      StudentRollWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StudentRoll.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StudentRollWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
