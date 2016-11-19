defmodule RabbitMusings.Mixfile do
  use Mix.Project

  def project do
    [app: :rabbit_musings,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:rabbit_common, git: "https://github.com/jbrisbin/rabbit_common.git", override: true},
      {:amqp_client, git: "https://github.com/jbrisbin/amqp_client.git", override: true},
      {:amqp, "~> 0.1.5"}
    ]
  end
end
