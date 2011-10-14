#########################################################################
# This is for examples purposes ONLY. Not to be used as anything else.
# 
# 2011, by Marcelo de Moraes Serpa
# twitter -> @fullofcaffeine
# fullofcaffeine.com
#
# boss < at > fullofcaffeine < !dot! > com
#########################################################################

require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'thin'
require 'amqp'
require 'ruby-debug'

INTRO_MESSAGES = %{Hi (nickname), welcome to the chat!
This application is implemented by creating a queue for each user that connects, Then, a fanout exchange 
named "sample" is created as well. The messages are sent to the fanout which in turn distribute them to 
the queues (chat users).
You can clone the code from github (https://github.com/celoserpa/conejito), run bundle install,
and run the cli_viewer.rb script. It will connect to the same RabbitMQ server and exchange, and will
receive the messages as well. The server IP is 174.120.132.97
By the way, these messages were sent using a Direct exchange bound to your user queue, so we have two exchanges:
1) The fanout one, that spreads the messages across ALL queues bound to it;
2) The direct one, a point-to-point communication channel to your queue (that's how you received these messages).
Check the code, and have fun ;)
(use /clear to get rid of this message.)
}

Sinatra.register Sinatra::Async

$queues = {}
$exchange = nil
$messages = {}


AMQP.start(:host => 'localhost', :user => 'guest', :pass => 'magmarails') do |connection|
  $channel = AMQP::Channel.new(connection)
  $exchange = $channel.fanout('sample')

  get '/app/setup' do
    if $queues[params[:nickname]]
      content_type 'text/javascript'
      return "alert('This nickname is already registered, please choose another one.');return false;"
    end

    nickname = params[:nickname] || "Rabbit#{rand.to_s.split('.')[1]}"
    $queues[nickname] = $channel.queue(nickname).bind($exchange, :auto_delete => true)
    $messages[nickname] = []
    $queues[params[:nickname]].subscribe(:ack => true) do |header,msg| 
      $messages[nickname] << msg 
      #Try removing this ack and entering the chat with an username that has been used before...
      #All the messages will be sent again
      header.ack
    end
    temp_direct_exchange = $channel.direct('intro_messages')
    $channel.queue(nickname).bind(temp_direct_exchange)
    msgs = INTRO_MESSAGES.gsub(/\(nickname\)/,nickname).split("\n").push("").reverse
    msgs.each do |msg|
      temp_direct_exchange.publish(msg)
    end
  end

  get '/app/broadcast_message' do
    $exchange.publish(params[:nickname] + ": " + params[:message]) 
  end

  #For long polling, we use EventMachine's defer to defer it in the background so 
  #sinatra can process new HTTP requests
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
      body($messages[params[:nickname]].pop)
    end
  end
  Sinatra::Application.run!
end

