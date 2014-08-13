# Promise HTTP

A simple wrapper for [q-io/http](https://github.com/kriskowal/q-io#requestrequest-object-or-url)
that handles erroneous responses and rejects the promise accordingly.

## Installation

`npm install promise-http --save`

## Usage

> The request can be anything that compatible with [q-io/http#request](https://github.com/kriskowal/q-io#requestrequest-object-or-url)

### GET

```javascript
Http = require('Http').client

request = Http.get('http://some.url').then(function(response){
   // you got the data
});

request.then(function(response){
    // done
}, function(reason){
    // something went wrong
});
```

### POST

```javascript
Http = require('Http').client

Http.post('http://some.url').then(function(response){
    // you know what to do...
});

request = Http.post({
    url: 'http://some.url',
    body: ['text'],
    headers: {'Content-Type': 'application/x-www-form-urlencoded'}
});

request.then(function(response){
    // all good.
});

request.fail(function(reason){
    // nope.
})
```

