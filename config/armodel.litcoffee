    _ = require 'lodash'
    stampit = require 'stampit'
    co = require 'co'

function to return [ActiveRecord](https://bfanger.nl/angular-activerecord/api/#!/api/ActiveRecord) like class for REST API access
```
baseUrl: base url to access REST API
```

    module.exports =
      armodel: (baseUrl) ->
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
              stamp = @getStamp()
              res = yield stamp.api.get stamp.url('read', _.pick(@, stamp.idAttribute))
              stamp.api.ok res, 200
              _.extend @, @parse res.body

- save object instance and input values to server via REST API

            save: (values = {}, opts = {}) ->
              {url} = opts
              _.extend @, values
              stamp = @getStamp()
              if @isNew()
                res = yield stamp.api.post url || stamp.url('create'), @, opts
                stamp.api.ok res, 201
                _.extend @, @parse res.body
              else
                res = yield stamp.api.put url || stamp.url('update', _.pick(@, stamp.idAttribute)), @, opts
                stamp.api.ok res, [200, 204]
                _.extend @, @parse res.body

- delete object instance from server via REST API

            destroy: ->
              stamp = @getStamp()
              res = yield stamp.api.delete stamp.url('delete', _.pick(@, stamp.idAttribute))
              stamp.api.ok res, [200, 204]
              @

          .statics

- default 'id' as the id attribute name

            idAttribute: 'id'

- base url to access server model data

            baseUrl: baseUrl

- default internal REST API implementation without oauth2 

            api: sails.config.api()

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

            url: (method = 'list', params = {}, idAttribute = @idAttribute) ->
              params[idAttribute] ?= '.'
              URL = require 'url'
              path = require 'path'
              obj = URL.parse @baseUrl
              obj.pathname =  path.join obj.pathname, params[idAttribute].toString()
              obj.query = _.omit params, idAttribute
              URL.format obj

- fetch object instance with input id from server

            fetchOne: (id) ->
              props = {}
              props[@idAttribute] = id
              yield @(props).fetch()

- fetch all object instances from server and return iterator
```
to override url or data with

opts =
  url: 'http://abc.com/api/model/full'
  data:
    createdBy: 'admin@abc.com'
    ...

Example:

  co proxy.fetchAll()
    .then (gen) ->
      for i from gen()
        console.log proxy
```

            fetchAll: (opts = {}) ->
              {url, data} = opts
              opts = _.omit opts, 'url', 'data'
              self = @
              skip = 0
              count = 0
              results = []
              cond = ->
                skip < count
              action = ->
                co self.api.get url || self.url('list', skip: skip), data, opts
                  .then (res) ->
                    self.api.ok res, 200
                    {body} = res
                    if Array.isArray body
                      data =
                        count: body.length
                        results: body
                      body = data
                    skip = skip + count
                    {count, results} = body
              yield sails.config.Promise.until cond, action
                .then -> ->
                  for i in results
                    yield i
