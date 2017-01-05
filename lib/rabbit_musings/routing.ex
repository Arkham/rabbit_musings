defmodule RabbitMusings.Routing do
  def emit_log(message, severities) do
    RabbitMusings.create_channel(fn channel ->
      AMQP.Exchange.declare(channel, "direct_logs", :direct)

      severities
      |> Enum.each(fn severity ->
        routing_key = severity |> to_string
        AMQP.Basic.publish(channel, "direct_logs", routing_key, message)
        IO.puts "[x] Sent '[#{severity}] #{message}'"
      end)
    end)
  end

  defmodule ReceiveLogs do
    def wait_for_messages(channel) do
      receive do
        {:basic_deliver, payload, meta} ->
          IO.puts "[x] Received [#{meta.routing_key}] #{payload}"

          wait_for_messages(channel)
      end
    end
  end

  def receive_logs(severities) do
    RabbitMusings.create_channel(fn channel ->
      AMQP.Exchange.declare(channel, "direct_logs", :direct)

      {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

      severities
      |> Enum.each(fn severity ->
        binding_key = severity |> to_string
        AMQP.Queue.bind(channel, queue_name, "direct_logs", routing_key: binding_key)
      end)

      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

      IO.puts "[*] Waiting for messages."

      ReceiveLogs.wait_for_messages(channel)
    end)
  end
end
