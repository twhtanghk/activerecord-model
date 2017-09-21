    _ = require 'lodash'
    assert = require 'assert'
    Promise = require 'bluebird'
    stampit = require 'stampit'
    http = Promise.promisifyAll require 'needle'
    co = require 'co'
    promiseWhile = require('promise-while')(Promise)
    promiseUntil = (cond, action) ->
      first = true
      skipFirst = ->
        if first
          first = false
          return true
        else
          cond()
      promiseWhile skipFirst, action


acquire token for resource owner password credentials grant from oauth2 server
```
opts:
  url: 
    token: url to acquire token
  client:
    id: client id
    secret: client secret
  user:
    user: user id
    secret: user secret
  scope: [
    'User'
   ...
  ]
```

    module.exports.token = (opts) ->
      {url, client, user, scope} = opts
      opts =
        'Content-Type': 'application/x-www-form-urlencoded'
        username: client.id
        password: client.secret
      data = {}
      if user?
        data =
          grant_type: 'password'
          username: user.id
          password: user.secret
          scope: scope.join(' ')
      else
        data =
          grant_type: 'client_credentials'
      {statusCode, statusMessage, body} = yield module.exports.api().post url.token, data, opts
      assert statusCode == 200 and not body.error?, "#{statusMessage}: #{body}"
      body.access_token

verify token with input url
```
opts:
  url:
    verify: url to verify token
  scope: [
    'User'
    ...
  ]
  token: token to be verified
```

    module.exports.verify = (opts) ->
      {url, scope, token} = opts
      opts =
        headers:
          Authorization: "Bearer #{token}"
      {statusCode, statusMessage, body} = yield module.exports.api().get(url.verify, null, opts)
      assert statusCode == 200, "#{statusMessage}: #{body}"
      result = _.intersection scope, body.scope.split(' ')
      assert result.length == scope.length, "Unauthorizated access to #{scope}"
      body 

function to acquire token even if expired
```
opts:
  getToken: function to acquire token
  url:
    verify: url to verify token
  scope: [
    'User'
    ...
  ]
```

    module.exports.validToken = (opts) ->
      cond = ->
        not opts.token
      action = -> co ->
        while true
          try
            {token, getToken, url, scope} = opts
            verified = yield module.exports.verify opts
            return opts.token
          catch err
            opts.token = yield getToken()
      yield promiseUntil cond, action
        .then ->
          opts.token
    
function to return http class with methods get, put, post, delete overriden

    module.exports.api = ->
      stamp = stampit()
        .compose http
        .statics
          get: (url, data, opts = {}) ->
            if data?
              opts.headers ?= {}
              _.extend opts.headers,
                'Content-Type': 'application/json'
                'x-http-method-override': 'get'
              yield http.postAsync url, data, opts
            else
              yield http.getAsync url, opts
          put: (url, data, opts) ->
            yield http.putAsync url, data, opts
          post: (url, data, opts) ->
            yield http.postAsync url, data, opts
          'delete': (url, data, opts) ->
            yield http.deleteAsync url, data, opts

function to return http class methods get, put, post, delete with oauth2 token acquried from function getToken
```
getToken: function to acquire token
```

    module.exports.authApi = (getToken) ->
      token = (opts) ->
        ret =
          rejectUnauthorized: false 
          headers:
            Authorization: "Bearer #{yield getToken()}"
        _.extend ret, opts
      api = module.exports.api()
      stampit()
        .compose api
        .statics
          get: (url, data, opts) ->
            opts = yield token opts
            yield api.get url, null, opts
          put: (url, data, opts) ->
            yield api.put url, data, yield token opts
          post: (url, data, opts) ->
            yield api.post url, data, yield token opts
          'delete': (url, data, opts) ->
            yield api.delete url, null, yield token opts

function to return [ActiveRecord](https://bfanger.nl/angular-activerecord/api/#!/api/ActiveRecord) like class for REST API access
```
baseUrl: base url to access REST API
```

    module.exports.model = (baseUrl) ->
      stamp = stampit()

- constructor to create object instance

        .init (props) ->
          _.extend @, @parse props

        .methods

          getStamp: ->
            stamp

- return if object instance created before or not

          isNew: ->
            not @[@getStamp().idAttribute]?

- conversion from server response to object internal respresentation

          parse: (data = {}) ->
            data

- fetch object instance via REST API

          fetch: ->
            res = yield stamp.api.get stamp.url('read', id: @[@getStamp().idAttribute])
            assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
            _.extend @, @parse res

- save object instance and input values to server via REST API

          save: (values = {}) ->
            _.extend @, values
            if @isNew()
              res = yield stamp.api.post stamp.url('create'), @
              assert res.statusCode == 201, "#{res.statusMessage}: #{res.body}"
              _.extend @, @parse res.body
            else
              res = yield stamp.api.put stamp.url('update', id: @[@getStamp().idAttribute]), @
              assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
              _.extend @, @parse res.body

- delete object instance from server via REST API

          destroy: ->
            res = yield stamp.api.delete stamp.url('delete', id: @[@getStamp().idAttribute])
            assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
            @

        .statics

- default 'id' as the id attribute name

          idAttribute: 'id'

- base url to access server model data

          baseUrl: baseUrl

- default internal REST API implementation without oauth2 

          api: module.exports.api()

- override internal REST API implementation

          use: (api) ->
            @api = api
            @

- static method to generate url based on input method and params
```
method: 'create', 'read', 'update', 'delete', or 'list'
params:
  id: id of object instance
  ...
```

          url: (method = 'list', params = {id: '.'}) ->
            _.defaults params, id: '.'
            URL = require 'url'
            path = require 'path'
            obj = URL.parse @baseUrl
            obj.pathname = path.join obj.pathname, id.toString()
            obj.query = _.omit params, 'id'
            URL.format obj

- fetch object instance with input id from server

          fetchOne: (id) ->
            props = {}
            props[@idAttribute] = id
            yield @(props).fetch()

- fetch all object instances from server and return iterator
```
co proxy.fetchAll()
  .then (gen) ->
    for i from gen()
      console.log proxy
```

          fetchAll: ->
            self = @
            skip = 0
            count = 0
            results = []
            cond = ->
              skip < count
            action = ->
              co self.api.get self.url(list, skip: skip)
                .then (res) ->
                  assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
                  {body} = res
                  if Array.isArray body
                    data =
                      count: body.length
                      results: body
                    body = data
                  skip = skip + count
                  {count, results} = body
            yield promiseUntil cond, action
              .then -> ->
                for i in results
                  yield i
