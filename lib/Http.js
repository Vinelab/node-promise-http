// Generated by CoffeeScript 1.7.1

/* Abed Halawi <abed.halawi@vinelab.com> */

(function() {
  var Http, Q, QHttp,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Http = (function() {

    /*
     * Create a new Http instance.
     *
     * @param {object} Q A promise manager.
     */
    function Http(Q, QHttp) {
      this.Q = Q;
      this.QHttp = QHttp;
      this.post = __bind(this.post, this);
      this.get = __bind(this.get, this);
      this.respond = __bind(this.respond, this);
    }


    /*
      * send an HTTP request
      *
      * @param {object|string} request Could be the request URL as a string or the request object,
      *                                 check https://github.com/kriskowal/q-io/#request
      *                                 for available request properties
     */

    Http.prototype.request = function(request) {
      var dfd;
      dfd = this.Q.defer();
      this.QHttp.request(request).then((function(_this) {
        return function(response) {
          return _this.respond(response, dfd);
        };
      })(this));
      return dfd.promise;
    };


    /*
     * Format a response and handle errors and resolve/reject
     * a deferred promise.
     *
     * @param {object} response
     * @param {object} dfd The promise
     * @return {void}
     */

    Http.prototype.respond = function(response, dfd) {
      if (this.validStatus(response.status)) {
        return dfd.resolve(response.body.read());
      } else {
        dfd.reject(response.node.read());
        return this.error(new Error(response.status));
      }
    };


    /*
     * Perform a GET rerquest.
     *
     * @param {string|object}
     * @return q A deferred promise.
     */

    Http.prototype.get = function(request) {
      if ((request != null) && typeof request !== 'string') {
        request.method = 'GET';
      }
      return this.request(request);
    };


    /*
     * Perform a POST request.
     *
     * @param {string|object}
     * @return q A deferred promise.
     */

    Http.prototype.post = function(request) {
      if ((request != null) && typeof request !== 'string') {
        request.method = 'POST';
      }
      if (typeof request === 'string') {
        request = {
          url: request,
          method: 'POST'
        };
      }
      return this.request(request);
    };

    Http.prototype.error = function(error) {
      throw error;
    };


    /*
      * validate HTTP response status code
      *
      * @param {integer|string} code
      * @return {boolean}
     */

    Http.prototype.validStatus = function(code) {
      var status;
      status = parseInt(code);
      if (status === 305 || status === 306) {
        return false;
      }
      return Boolean(status >= 200 && status < 400);
    };

    return Http;

  })();

  module.exports.klass = Http;

  module.exports.instance = function(Q, QHttp) {
    return new Http(Q, QHttp);
  };

  Q = require('q');

  QHttp = require('q-io/http');

  module.exports.client = new Http(Q, QHttp);

}).call(this);
