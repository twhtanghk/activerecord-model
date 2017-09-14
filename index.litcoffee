    _ = require 'lodash'
    assert = require 'assert'
    {async, await} = require 'asyncawait'
    Promise = require 'bluebird'
    stampit = require 'stampit'
    http = Promise.promisifyAll require 'needle'

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

    module.exports.token = async (opts) ->
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
      {statusCode, statusMessage, body} = await module.exports.api().post url.token, data, opts
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

    module.exports.verify = async (opts) ->
      {url, scope, token} = opts
      opts =
        headers:
          Authorization: "Bearer #{token}"
      {statusCode, statusMessage, body} = await module.exports.api().get(url.verify, null, opts)
      assert statusCode == 200, "#{statusMessage}: #{body}"
      result = _.intersection scope, body.scope.split(' ')
      assert result.length == scope.length, "Unauthorizated access to #{scope}"
      body 

async function to acquire token even if expired
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

    module.exports.validToken = async (opts) ->
      {getToken, url, scope} = opts
      token = null
      while true
        try
          verified = await module.exports.verify _.extend(token: token, opts)
          return token
        catch err
          token = await getToken()
     
function to return http class with methods get, put, post, delete overriden

    module.exports.api = ->
      stamp = stampit()
        .compose http
        .statics
          get: async (url, data, opts = {}) ->
            if data?
              opts.headers ?= {}
              _.extend opts.headers,
                'Content-Type': 'application/json'
                'x-http-method-override': 'get'
              await http.postAsync url, data, opts
            else
              await http.getAsync url, opts
          put: async (url, data, opts) ->
            await http.putAsync url, data, opts
          post: async (url, data, opts) ->
            await http.postAsync url, data, opts
          'delete': async (url, data, opts) ->
            await http.deleteAsync url, data, opts

function to return http class methods get, put, post, delete with oauth2 token acquried from oauth2 server
```
getToken: async function to acquire token
```

    module.exports.authApi = (getToken) ->
      token = async (opts) ->
        ret =
          rejectUnauthorized: false 
          headers:
            Authorization: "Bearer #{await getToken()}"
        _.extend ret, opts
      api = module.exports.api()
      stampit()
        .compose api
        .statics
          get: async (url, data, opts) ->
            opts = await token opts
            await api.get url, opts
          put: async (url, data, opts) ->
            await api.put url, data, await token opts
          post: async (url, data, opts) ->
            await api.post url, data, await token opts
          'delete': async (url, data, opts) ->
            await api.delete url, null, await token opts

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

          fetch: async ->
            res = await stamp.api.get stamp.url(@[@getStamp().idAttribute])
            assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
            _.extend @, @parse res

- save object instance and input values to server via REST API

          save: async (values = {}) ->
            _.extend @, values
            if @isNew()
              res = await stamp.api.post stamp.url(), @
              assert res.statusCode == 201, "#{res.statusMessage}: #{res.body}"
              _.extend @, @parse res.body
            else
              res = await stamp.api.put stamp.url(@[@getStamp().idAttribute]), @
              assert res.statusCode == 200, "#{res.statusMessage}: #{res.body}"
              _.extend @, @parse res.body

- delete object instance from server via REST API

          destroy: ->
            res = await stamp.api.delete stamp.url(@[@getStamp().idAttribute])
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

- static method to generate url based on input id

          url: (id = '.', params = null) ->
            URL = require 'url'
            path = require 'path'
            obj = URL.parse @baseUrl
            obj.pathname = path.join obj.pathname, id
            obj.query = params
            URL.format obj

- fetch object instance with input id from server

          fetchOne: async (id) ->
            props = {}
            props[@idAttribute] = id
            await @(props).fetch()

- fetch all object instances from server and return async iterator
```
proxy.fetchAll().forEach (proxy) ->
  console.log proxy
```

          fetchAll: async ->
            skip = 0
            done = false
            while not done
              data = await @api.get @url('.', skip: skip)
              if Array.isArray data
                data =
                  count: data.length
                  results: data
              {count, results} = data
              skip = skip + data.results.length
              done = skip >= count
              for i in data
                yield i
