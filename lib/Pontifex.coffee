# Pontifex.coffee
#
# (c) 2013 Dave Goehrig <dave@dloh.org>
#
# Pontifex is a "bridge maker"
#
# 	Pontifex instantiates a bridge object which implements a protocol bridge,
# 	For example:
#
#		Pontifex = require 'pontifex'
# 		pons = Pontifex 'amqp://user:password@host:port/domain/exchange/key/'
# 		pons('http://localhost:8080/')
#
# 	Will bridge HTTP traffic on localhost:8080 to amqp on host:port writing to /exchange/key/ 

amqp = require 'amqp'

Pontifex = (AmqpUrl) ->
	[ proto, user, password, host, port, domain ] = AmqpUrl.match(///([^:]+)://([^:]+):([^@]+)@([^:]+):(\d+)/([^\/]*)///)[1...]
	self = (Url,args...) ->
		[ protocol] = Url.match(///([^:]+):///)[1...]
		self.connection = amqp.createConnection
			host: host,
			port: port,
			login: user,
			password: password,
			vhost: domain || '/'
		self.connection.on 'error', (Message) ->
			console.log "Connection error", Message
		self.connection.on 'end', () ->
			console.log "Connection closed"
		self.connection.on 'ready', () ->
			self[protocol] ?= require "pontifex.#{protocol}"
			self[protocol]?.apply(self[protocol], [self,Url].concat(args))
		self
	self.exchanges = {}
	self.queues = {}
	self.create = (exchange,key,queue) ->
		self.connection?.exchange exchange, { durable: false, type: 'topic', autoDelete: true },  (Exchange) ->
			self.exchanges[exchange] = Exchange
		if queue
			self.connection?.queue queue, (Queue) ->
				self.queues[queue] = Queue
				Queue.bind exchange, key
	self.read = (queue,fun) ->
		# reads a message from the given queue and returns the result to the supplied callback
		if not self.queues[queue]
			self.connection?.queue queue, (Queue) ->
				self.queues[queue] = Queue
				Queue.get({ noack: true }, fun)
		else
			self.queues[queue].get({ noack: true }, fun)
	self.update = (exchange,key,msg) ->
		# publishes a message to the given exchange with the supplied routing key
		if not self.exchanges[exchange]
			self.connection?.exchange exchange, { durable: false, type: 'topic', autoDelete: true }, (Exchange) ->
				self.exchanges[exchange] = Exchange
				Exchange.publish(key,msg)
		else
			self.exchanges[exchange].publish(key,msg)
	self.delete = (queue) ->
		# deletes a queue, unbinding it in the proces
		if not self.queues[queue]
			self.connection?.queue queue, (Queue) ->
				Queue.destroy()
		else
			self.queues[queue]?.destroy()
			self.queues[queue] = false
	self.subscribe = (queue,listener) ->
		if not self.queues[queue]
			self.connection?.queue queue, (Queue) ->
				self.queues[queue] = Queue
				Queue.subscribe { ack: false, prefetchCount: 1 }, (message, headers, deliveryInfo) ->
					listener(message.data.toString())
		else
			self.queues[queue].subscribe { ack: false, prefetchCount: 1 },  (message, headers, deliveryInfo) ->
				listener(message.data.toString())
	self

module.exports = Pontifex
