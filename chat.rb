require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'thin'
require 'amqp'
require 'ruby-debug'


Sinatra.register Sinatra::Async

$queues = {}
$exchange = nil
$messages = {}

AMQP.start(:host => 'localhost', :user => 'guest', :pass => 'magmarails') do |connection|
    get '/app/setup' do
      nickname = params[:nickname] || "Rabbit#{rand.to_s.split('.')[1]}"
      channel = AMQP::Channel.new(connection)
      $exchange = channel.fanout('sample')
      $queues[nickname] = channel.queue("").bind($exchange)
      $messages[nickname] = []
      $queues[params[:nickname]].subscribe(:ack => true) do |header,msg| 
       $messages[nickname] << msg 
      end
    end

    get '/app/broadcast_message' do
      if $exchange.publish(params[:message]) 
        "OK"
      else
        "FAIL"
      end
    end

    aget '/app/fetch_messages' do
      EM.defer do
        time = 0 
        until time > 100
          count = $messages[params[:nickname]].length
          puts "*** count == " + count.to_s
          break if count > 0
          sleep 0.5
          time += 0.5
        end
        content_type 'text/plain'
        body(params[:nickname] + ": " + $messages[params[:nickname]].pop)
      end
    end
    Sinatra::Application.run!
end

