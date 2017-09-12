_ = require 'lodash'
{async, await} = require 'asyncawait'
Promise = require 'bluebird'
stampit = require 'stampit'
http = Promise.promisifyAll require 'needle'

module.exports =
  # opts:
  #  url: 
  #    token: url to acquire token
  #  client:
  #    id: client id
  #    secret: client secret
  #  user:
  #    user: user id
  #    secret: user secret
  #  scope: [
  #    'User'
  #    ...
  #  ]
  token: async (opts) ->
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

  verify: (opts) ->
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

  # async function to acquire token even if expired
  # getToken: function to acquire token
  # opts:
  #   url:
  #     verify: url to verify token
  #   scope: [
  #     'User'
  #     ...
  #   ]
  validToken: async (getToken, opts) ->
    token = null
    while true
      try
        verified = await module.exports.verify _.extend(token: token, opts)
        return token
      catch err
        token = await getToken()
     
  api: ->
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

  # token: async function to acquire token
  authApi: (token) ->
    opts = async ->
      rejectUnauthorized: false 
      headers:
        Authorization: "Bearer #{await token()}"
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

  # baseUrl: baseUrl to access the restful data
  model: (baseUrl) ->
    stamp = stampit()
      .init (props) ->
        _.extend @, @parse props
      .methods
        getStamp: ->
          stamp
        isNew: ->
          not @[@getStamp().idAttribute]?
        parse: (data = {}) ->
          data
        fetch: async ->
          res = await stamp.api.get stamp.url(@[@getStamp().idAttribute])
          _.extend @, @parse res
        save: async (values = {}) ->
          _.extend @, values
          if @isNew()
            res = await stamp.api.post stamp.url(), @
          else
            res = await stamp.api.put stamp.url(@[@getStamp().idAttribute]), @
          _.extend @, @parse res
        destroy: ->
          await stamp.api.delete stamp.url(@[@getStamp().idAttribute])
      .statics
        idAttribute: 'id'
        baseUrl: baseUrl
        api: module.exports.api()
        use: (api) ->
          @api = api
        url: (id = '.') ->
          url = require 'url'
          path = require 'path'
          ret = url.parse @baseUrl
          ret.pathname = path.join ret.pathname, id
          url.format ret
        fetchOne: async (id) ->
          props = {}
          props[@idAttribute] = id
          await @(props).fetch()
        fetchAll: async (data = null) ->
          await @api.get stamp.url
