defmodule RabbitMusings.HelloWorld do
  def send do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Queue.declare(channel, "hello")
      AMQP.Basic.publish(channel, "", "hello", "Hello World!")
      IO.puts "[x] Sent 'Hello World!'"
    end)
  end

  defmodule Receive do
    def wait_for_messages do
      receive do
        {:basic_deliver, payload, _meta} ->
          IO.puts "[x] Received #{payload}"
          wait_for_messages
      end
    end
  end

  def receive do
    RabbitMusings.create_channel(fn(channel) ->
      AMQP.Queue.declare(channel, "hello")
      AMQP.Basic.consume(channel,
                         "hello",
                         nil, # consumer process, defaults to self()
                         no_ack: true)
      IO.puts "[*] Waiting for messages. To exit press CTRL+C, CTRL+C"

      Receive.wait_for_messages()
    end)
  end
end
