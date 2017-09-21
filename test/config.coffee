{model, token} = require '../index'

module.exports =
  oauth2:
    url:
      verify: 'https://abc.com/auth/oauth2/verify/'
      token: 'https://abc.com/auth/oauth2/token/'
    client:
      id: 'client_id'
      secret: 'client_secret'
    user:
      id: 'user_id'
      secret: 'user_secret'
    scope: [
      'User'
    ]
  proxy:
    url: 'https://abc.com/upstream' # for testing only
    model: ->
      model module.exports.proxy.url
        .use ->
          {url, client, user, scope} = module.exports.oauth2
          token url.token, client, user, scope
  docker:
    url: 'http://192.168.122.2:2375'
    model:
      container: ->
        ret = model "#{module.exports.docker.url}/containers"
        ret
          .statics
            url: (method = 'list', params = {id: '.'}) ->
              append = (url, path) ->
                URL = require 'url'
                obj = URL.parse url
                {join} = require 'path'
                obj.pathname = join obj.pathname, path
                URL.format obj
              switch method
                when 'create'
                  append ret.url(method, params), 'create'
                when 'update'
                  append ret.url(method, params), 'update'
                when 'delete'
                  ret.url method, params
                else # read or list
                  append ret.url(method, params), 'json'
