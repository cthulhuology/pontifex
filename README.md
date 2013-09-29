pontifex
========

A protocol bridge maker


Getting Started
---------------

        
        pontifex = require 'pontifex'
        pons = pontifex('amqp://user:password@host:port/domain/exchange/key/queue...')
        server.on 'request', (req,res) ->
                if req.method == "POST"
                        pons.create req.url
                
        
Building Bridges
================


Pontifex provides a standard interface for building bridges between protocols and AMQP.  It is based on a generalizable mapping of CRUD and REST to a more statefull system. Pontifex generates a bridge object (pons) that exports 4 methods create, read, update, delete which act upon AMQP streams. Streams are defined by a path specification:

        /<domain>/<exchange>/<key>/[<queue>/[<destination exchange>/<destination key>]]

This path specification has 3 basic modes:

* producer - /<domain>/<destination exchange>/<destination key>/ for publishing to the given exchange with key on domain
* consumer - /<domain>/<source exchange>/<source key>/<source queue>/ for subscribing to a given queue with exchange and key bindings on a domain
* pipe - /<domain>/<source exchange>/<source key>/<source queue>/<destination exchange>/<destination key> for filtering a stream taking data in from a source, transforming, and then publishing to a destination exchange with key

These methods are used as follows:

create( stream )
------------------

This method creates a persistent queue bound to the specified exchange with the given routing key on a specific domain. 

