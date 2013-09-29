pontifex
========

A protocol bridge maker


Getting Started
---------------

        
        pontifex = require 'pontifex'
        pons = pontifex('amqp://user:password@host:port/domain/exchange/queue/key...')
        server.on 'request', (req,res) ->
                if req.method == "POST"
                        pons.create req.url
                
        
Building Bridges
================


Pontifex provides a standard interface for building bridges between protocols and AMQP.  It is based on a generalizable mapping of CRUD and REST to a more statefull system. Pontifex generates a bridge object (pons) that exports 4 methods create, read, update, delete which act upon AMQP streams. Streams are defined by a path specification:

        /<domain>/<exchange>/<key>/[<queue>/][<destination exchange>/<destination key>]



These methods are used as follows:

create( stream )
------------------

This method creates a persistent queue bound to the specified exchange with the given routing key on a specific domain. 

