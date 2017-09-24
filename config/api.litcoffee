    _ = require 'lodash'
    co = require 'co'
    util = require 'util'
    assert = require 'assert'
    stampit = require 'stampit'

    module.exports =
    
function to return http class with methods get, put, post, delete overriden

      api: ->
        Promise = arModel.Promise
        http = Promise.promisifyAll require 'needle'
        stamp = stampit()

          .compose http

          .statics

list of middleware for customizing http opts

            mw: []

            get: (url, data, opts = {}) ->
              if data?
                opts.headers ?= {}
                _.extend opts.headers,
                  'Content-Type': 'application/json'
                  'x-http-method-override': 'get'
                yield http.postAsync url, data, yield @getOpts(opts)
              else
                yield http.getAsync url, yield @getOpts(opts)

            put: (url, data, opts) ->
              yield http.putAsync url, data, yield @getOpts(opts)

            post: (url, data, opts) ->
              yield http.postAsync url, data, yield @getOpts(opts)

            'delete': (url, data, opts) ->
              yield http.deleteAsync url, data, yield @getOpts(opts)

check if res is ok, throw error message with res.sttatuMessage and res.body

            ok: (res, code) ->
              if not Array.isArray code 
                code = [code]
              {statusCode, statusMessage, body} = res
              assert statusCode in code and not body.error?, "#{statusMessage}: #{util.inspect body}"

loop for all defined middleware for customizing input opts

            getOpts: (opts) ->
              i = 0
              cond = =>
                i < @mw.length
              action = =>
                opts = co @mw[i++](opts)
              Promise
                .while cond, action
                .then ->
                  opts
                
add middleware function to customize opts 
```
customOpts = (opts) ->
  ret =
    rejectUnauthorized: false
    headers:
      Authorization: "Bearer #{yield arModel.oauth2.validToken()}"
    _.extend ret, opts
```

            use: (customOpts) ->
              @mw.push customOpts
              @
