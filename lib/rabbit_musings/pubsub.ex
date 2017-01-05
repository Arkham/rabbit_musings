defmodule RabbitMusings.PubSub do
  def emit_log(message) do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Exchange.declare(channel, "logs", :fanout)
      AMQP.Basic.publish(channel, "logs", "", message)
      IO.puts "[x] Sent #{message}"
    end)
  end

  defmodule ReceiveLogs do
    def wait_for_messages(channel) do
      receive do
        {:basic_deliver, payload, _meta} ->
          IO.puts "[x] Received #{payload}"

          wait_for_messages(channel)
      end
    end
  end

  def receive_logs do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Exchange.declare(channel, "logs", :fanout)
      {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
      AMQP.Queue.bind(channel, queue_name, "logs")
      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
      IO.puts "[*] Waiting for messages."

      ReceiveLogs.wait_for_messages(channel)
    end)
  end
end
