# Tame The F* (fine) Rabbit, The Chat
###aka Conjito

A sample application for my 2011 MagmaRails presentation.

It's a chat webapp and a CLI ruby script that uses AMQP through RabbitMQ (and ruby-amqp) to implement a very simple chat app. The CLI script is just a viewer, to show how a another
consumer from a different platform can subscribe and consume messages from the same (fanout) exchange.

The chat web app uses two exchanges. The one that distributes the chat messages across the different users (queues) is of type FANOUT. There's another one that I create as a way to show how a DIRECT 
(point-to-point) exchange works.

Instructions TBD

2011,Marcelo de Moraes Serpa.


