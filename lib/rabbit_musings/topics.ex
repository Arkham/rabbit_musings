defmodule RabbitMusings.Topics do
  def emit_log(message, topic \\ "anonymous.info") do
    RabbitMusings.create_channel(fn channel ->
      AMQP.Exchange.declare(channel, "topic_logs", :topic)
      AMQP.Basic.publish(channel, "topic_logs", topic, message)
      IO.puts "[x] Sent '[#{topic}] #{message}'"
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

  def receive_logs(topics \\ ["anonymous.info"]) do
    RabbitMusings.create_channel(fn channel ->
      AMQP.Exchange.declare(channel, "topic_logs", :topic)
      {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

      topics
      |> Enum.each(fn topic ->
        binding_key = topic |> to_string
        AMQP.Queue.bind(channel, queue_name, "topic_logs", routing_key: binding_key)
      end)

      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
      IO.puts "[*] Waiting for messages."

      ReceiveLogs.wait_for_messages(channel)
    end)
  end
end
