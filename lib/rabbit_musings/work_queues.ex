defmodule RabbitMusings.WorkQueues do
  def new_task(message) when is_binary(message) do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Queue.declare(channel, "task_queue", durable: true)
      AMQP.Basic.publish(channel, "", "task_queue", message, persistent: true)
      IO.puts "[x] Sent '#{message}'"
    end)
  end
  def new_task(words) when is_list(words) do
    new_task(Enum.join(words, " "))
  end
  def new_task do
    new_task("Hello World")
  end

  defmodule Worker do
    def wait_for_messages(channel) do
      receive do 
        {:basic_deliver, payload, meta} ->
          IO.puts "[x] Received #{payload}"
          payload
          |> to_char_list
          |> Enum.count(&(&1 == ?.))
          |> Kernel.*(1000)
          |> :timer.sleep
          IO.puts "[x] Done."
          AMQP.Basic.ack(channel, meta.delivery_tag)

          wait_for_messages(channel)
      end
    end
  end

  def worker do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Queue.declare(channel, "task_queue", durable: true)
      AMQP.Basic.qos(channel, prefetch_count: 1)

      AMQP.Basic.consume(channel, "task_queue")
      IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

      Worker.wait_for_messages(channel)
    end)
  end
end
