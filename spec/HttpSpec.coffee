describe 'Http', ->

    Q = {
        defer: -> return this
        reject: (data)->
        resolve: (data)->
        promise: -> return this
    }

    QHttp = {
        request: -> return this
        then: (promised)-> promised(@response)
        response:
            status: 200
            node: {
                read: -> return {status: 400, error: 'Bad Request'}
            }
            body: {
                read: -> return 'some data'
            }
    }

    Http = {}

    beforeEach ->

        Http = require('../lib/Http').instance(Q, QHttp)

    it 'promises to respond to a request when status code is 200', ->
        spyOn(Q, 'resolve')
        spyOn(Q, 'defer').and.callThrough()
        spyOn(Q, 'promise').and.callThrough()
        spyOn(QHttp, 'then').and.callThrough()
        spyOn(QHttp, 'request').and.callThrough()
        spyOn(Http, 'respond').and.callThrough()

        expect(Http.request('http://some.url')).toBe(Q.promise)

        expect(Q.defer).toHaveBeenCalled()
        expect(QHttp.request).toHaveBeenCalledWith('http://some.url')
        expect(Http.respond).toHaveBeenCalledWith(QHttp.response, Q)
        expect(Q.resolve).toHaveBeenCalledWith('some data')

    it 'validates the status b/w 200 and 400 (400 not included)', ->
        # -- 2xx
        # OK
        expect(Http.validStatus(200)).toBeTruthy()
        # Created
        expect(Http.validStatus(201)).toBeTruthy()
        # Accepted
        expect(Http.validStatus(202)).toBeTruthy()
        # Non-authoritative information
        expect(Http.validStatus(203)).toBeTruthy()
        # No content
        expect(Http.validStatus(204)).toBeTruthy()
        # Reset content
        expect(Http.validStatus(205)).toBeTruthy()
        # Partial content
        expect(Http.validStatus(206)).toBeTruthy()
        # Multi-status
        expect(Http.validStatus(207)).toBeTruthy()
        # Already reported
        expect(Http.validStatus(208)).toBeTruthy()
        # IM used
        expect(Http.validStatus(226)).toBeTruthy()
        # -- 3xx
        # Multiple choices
        expect(Http.validStatus(300)).toBeTruthy()
        # Moved permanently
        expect(Http.validStatus(301)).toBeTruthy()
        # Found
        expect(Http.validStatus(302)).toBeTruthy()
        # See other
        expect(Http.validStatus(303)).toBeTruthy()
        # Not modified
        expect(Http.validStatus(304)).toBeTruthy()
        # Use proxy
        expect(Http.validStatus(305)).toBeFalsy()
        # Switch proxy
        expect(Http.validStatus(306)).toBeFalsy()
        # Temporary redirect
        expect(Http.validStatus(307)).toBeTruthy()
        # Permanent redirect
        expect(Http.validStatus(308)).toBeTruthy()

    it 'rejects the promise when status code is invalid', ->
        spyOn(Q, 'reject')
        spyOn(Http, 'error')

        dfd = jasmine.createSpyObj('dfd', ['reject'])
        # Set an error code on the response
        response = QHttp.response
        response.status = 400

        Http.respond(response, dfd)
        expect(dfd.reject).toHaveBeenCalledWith({status: 400, error: 'Bad Request'})

        QHttp.response.status = 400
        expect(Http.request('http://some.url')).toBe(Q.promise)
        expect(Q.reject).toHaveBeenCalledWith({status: 400, error: 'Bad Request'})

        QHttp.response.status = 404
        expect(Http.request('http://non-existing.url')).toBe(Q.promise)
        expect(Q.reject).toHaveBeenCalledWith({status: 400, error: 'Bad Request'})

    it 'passes through the request when GETting with a url as a string', ->
        spyOn(Http, 'request')

        Http.get('http://get.this.url')
        expect(Http.request).toHaveBeenCalledWith('http://get.this.url')

    it '.get() changes the request method to GET when sending an object', ->
        spyOn(Http, 'request')

        request = {url: 'http://url', method: 'POST', headers:['Content-Type: application/json']}
        Http.get(request)
        # change method to check that the sent object is equivalend
        # except for the request method.
        request.method = 'GET'
        expect(Http.request).toHaveBeenCalledWith(request)

        request = {url: 'http://another.url', method: 'IDONOTKNOWTHIS'}
        Http.get(request)
        request.method = 'GET'
        expect(Http.request).toHaveBeenCalledWith(request)

    it 'performs a post request with a url as a string', ->
        spyOn(Http, 'request')

        url = 'http://post.to.this'
        Http.post(url)
        expect(Http.request).toHaveBeenCalledWith({url: url, method: 'POST'})

    it '.post() changes the request method to POST when sending object', ->
        spyOn(Http, 'request')

        request = {url: 'http://url', method: 'GET', headers:['Bearer: Token']}
        Http.post(request)
        # change method to check that the sent object is equivalend
        # except for the request method.
        request.method = 'POST'
        expect(Http.request).toHaveBeenCalledWith(request)

        request = {url: 'http://another.url', method: 'SOMETHINGHERE'}
        Http.post(request)
        request.method = 'POST'
        expect(Http.request).toHaveBeenCalledWith(request)

