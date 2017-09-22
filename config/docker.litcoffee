    _ = require 'lodash'

    module.exports =
      docker:
        url: 'http://192.168.122.2:2375'
        model:
          container: ->
            model = arModel
              .model "#{module.exports.docker.url}/containers"
            model = model
              .use model.api.use (opts) ->
                _.extend headers: 'Content-Type' : 'application/json', opts
            stamp = model
              .statics
                idAttribute: 'Id'
                url: (method = 'list', params = {id: '.'}) ->
                  append = (url, path) ->
                    URL = require 'url'
                    obj = URL.parse url
                    {join} = require 'path'
                    obj.pathname = join obj.pathname, path
                    URL.format obj
                  switch method
                    when 'create', 'update', 'start', 'stop'
                      append model.url(method, params), method
                    when 'delete'
                      model.url method, params
                    else # read or list
                      append model.url(method, params), 'json'
              .methods
                getStamp: ->
                  stamp
                start: ->
                  res = yield stamp.api.post stamp.url 'start',
                    id: @[stamp.idAttribute]
                  stamp.api.ok res, 204
                stop: ->
                  res = yield stamp.api.post stamp.url 'stop',
                    id: @[stamp.idAttribute]
                  stamp.api.ok res, 204
