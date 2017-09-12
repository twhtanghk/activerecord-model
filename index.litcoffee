    _ = require 'lodash'
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
      {body} = await module.exports.api().post url.token, data, opts
      if body.error?
        throw new Error body.error
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
      res = await module.exports.api().get url.verify, null, opts
      if res.statusCode != 200
        throw new Error res.body
      authScope = res.body.scope.split ' '
      result = _.intersection scope, authScope 
      if result.length != scope.length
        throw new Error "Unauthorizated access to #{scope}"
      res.body 

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
      opts = async ->
        rejectUnauthorized: false 
        headers:
          Authorization: "Bearer #{await getToken()}"
      api = module.exports.api()
      stampit()
        .compose api
        .statics
          get: async (url, data) ->
            await api.get url, await opts()
          put: async (url, data) ->
            await api.put url, data, await opts()
          post: async (url, data) ->
            await api.post url, data, await opts()
          'delete': async (url) ->
            await api.delele url, null, await opts()

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
            _.extend @, @parse res

- save object instance and input values to server via REST API

          save: async (values = {}) ->
            _.extend @, values
            if @isNew()
              res = await stamp.api.post stamp.url(), @
            else
              res = await stamp.api.put stamp.url(@[@getStamp().idAttribute]), @
            _.extend @, @parse res

- delete object instance from server via REST API

          destroy: ->
            await stamp.api.delete stamp.url(@[@getStamp().idAttribute])

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

          url: (id = '.') ->
            url = require 'url'
            path = require 'path'
            ret = url.parse @baseUrl
            ret.pathname = path.join ret.pathname, id
            url.format ret

- fetch object instance with input id from server

          fetchOne: async (id) ->
            props = {}
            props[@idAttribute] = id
            await @(props).fetch()

- fetch all object instances from server

          fetchAll: async (data = null) ->
            await @api.get stamp.url
