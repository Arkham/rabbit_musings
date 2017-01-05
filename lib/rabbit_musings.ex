defmodule RabbitMusings do
  def create_channel(callback_fn) do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)

    try do
      callback_fn.(channel)
    after
      AMQP.Connection.close(connection)
    end
  end
end
