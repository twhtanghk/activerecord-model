    _ = require 'lodash'

    module.exports =
      docker:
        url: 'http://10.0.2.15:2375'
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
                url: (method = 'list', params = {}, idAttribute = @idAttribute) ->
                  params[idAttribute] ?= '.'
                  append = (url, path) ->
                    URL = require 'url'
                    obj = URL.parse url
                    {join} = require 'path'
                    obj.pathname = join obj.pathname, path
                    URL.format obj
                  switch method
                    when 'create', 'update', 'start', 'stop'
                      append model.url(method, params, idAttribute), method
                    when 'delete'
                      model.url method, params, idAttribute
                    else # read or list
                      append model.url(method, params, idAttribute), 'json'
              .methods
                getStamp: ->
                  stamp
                start: ->
                  res = yield model.api.post stamp.url 'start',
                    _.pick @, stamp.idAttribute
                  model.api.ok res, 204
                stop: ->
                  res = yield model.api.post stamp.url 'stop',
                    _.pick @, stamp.idAttribute
                  model.api.ok res, 204
