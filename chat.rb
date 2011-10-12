require 'rubygems'
require 'sinatra'
require 'thin'
require 'amqp'
require 'ruby-debug'

$queues = {}

$exchange = nil

AMQP.start(:host => 'localhost', :user => 'guest', :pass => 'magmarails') do |connection|
    get '/setup' do
      nickname = params[:nickname] || "Rabbit#{rand.to_s.split('.')[1]}"
      channel = AMQP::Channel.new(connection)
      $exchange = channel.fanout('sample')
      $queues[nickname] = channel.queue("").bind($exchange)
    end

    get '/broadcast_message' do
      if $exchange.publish(params[:message]) 
        "OK"
      else
        "FAIL"
      end
    end

    get '/fetch_messages' do
      $queues[params[:nickname]].pop do |metadata,payload|
        puts payload.inspect
      end
    end
    Sinatra::Application.run!
end

