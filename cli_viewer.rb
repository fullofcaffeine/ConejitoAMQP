require 'rubygems'
require 'bundler'
require 'readline'
Bundler.require(:default)

host = ''

while host == ''
  host = Readline.readline('AMQP server host: ', true)
end

AMQP.start(:host => host, :user => 'guest',:password => 'magmarails') do |connection|
  puts 'Ready...'
  #We connect to the queue
  queue = AMQP.channel.queue("")
  #We declare the exchange type
  exchange = AMQP.channel.fanout('sample')
  #We make the binding between the two
  queue.bind(exchange)
  #And finally subscribe to the queue. We can then process the messages
  #the way we see fit.
  queue.subscribe(:ack => true) do |header, msg|
    puts msg
    header.ack
  end

end

