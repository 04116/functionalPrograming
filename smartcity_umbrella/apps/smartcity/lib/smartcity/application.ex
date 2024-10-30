defmodule Smartcity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Smartcity.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:smartcity, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:smartcity, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Smartcity.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Smartcity.Finch}
      # Start a worker by calling: Smartcity.Worker.start_link(arg)
      # {Smartcity.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Smartcity.Supervisor)
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
