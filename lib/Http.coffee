### Abed Halawi <abed.halawi@vinelab.com> ###
class Http

    ###
    # Create a new Http instance.
    #
    # @param {object} Q A promise manager.
    ###
    constructor: (@Q, @QHttp)->

    ###
     # send an HTTP request
     #
     # @param {object|string} request Could be the request URL as a string or the request object,
     #                                 check https://github.com/kriskowal/q-io/#request
     #                                 for available request properties
    ###
    request: (request)->
        dfd = @Q.defer()
        @QHttp.request(request).then (response)=> @respond(response, dfd)
        return dfd.promise

    ###
    # Format a response and handle errors and resolve/reject
    # a deferred promise.
    #
    # @param {object} response
    # @param {object} dfd The promise
    # @return {void}
    ###
    respond: (response, dfd)=>
        if @validStatus response.status
            dfd.resolve(response.body.read())
        else
            dfd.reject new Error(response.status)
            @error new Error(response.status)

    ###
    # Perform a GET rerquest.
    #
    # @param {string|object}
    # @return q A deferred promise.
    ###
    get: (request)=>
        request.method = 'GET' if request? and typeof request isnt 'string'
        return @request(request)

    ###
    # Perform a POST request.
    #
    # @param {string|object}
    # @return q A deferred promise.
    ###
    post: (request)=>
        request.method = 'POST' if request? and typeof request isnt 'string'
        request = {url: request, method: 'POST'} if typeof request is 'string'
        return @request(request)

    error: (error)-> throw error

    ###
     # validate HTTP response status code
     #
     # @param {integer|string} code
     # @return {boolean}
    ###
    validStatus: (code)->
        status = parseInt(code)
        return false if status is 305 or status is 306
        Boolean status >= 200 and status < 400

# Export the class to allow inheritance.
module.exports.klass = Http

# Export the instance to allow testability (DI)
module.exports.instance = (Q, QHttp)-> new Http(Q, QHttp)

# Export the client.
Q = require 'q'
QHttp = require 'q-io/http'

module.exports.client = new Http(Q, QHttp)
