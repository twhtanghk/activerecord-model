_ = require 'lodash'
Promise = require 'bluebird'
{token, verify, validToken, api, authApi, model} = require '../index'
config = require './config.coffee'
co = require 'co'

describe 'stamp', ->
  opts = _.extend config.oauth2, getToken: ->
    yield token opts
  Proxy = model config.proxy.url
    .use authApi ->
      yield validToken opts
  proxy = null

  it 'api', ->
    co api().get config.oauth2.url.token

  it 'token', -> 
    co opts.getToken

  it 'verify token', ->
    co ->
      yield verify _.extend token: yield opts.getToken(), _.pick(opts, 'url', 'scope')

  it 'verify null', ->
    co -> yield verify _.pick(opts, 'url', 'scope')
      .then Promise.reject
      .catch (err) ->
         Promise.resolve()

  it 'validToken', ->
    co validToken opts
      .then console.log

  it 'authApi', ->
    co authApi ->
      yield validToken opts

  it 'proxy create', ->
    co ->
      proxy = new Proxy
        name: 'test'
        prefix: '/test/'
        target: 'http://192.168.1.1'
      yield proxy.save()

  it 'proxy destroy', ->
    co ->
      yield proxy.destroy()

  it 'proxy fetchAll', ->
    co Proxy.fetchAll()
      .then (gen) ->
        for i from gen()
          console.log i
