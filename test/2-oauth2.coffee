_ = require 'lodash'
co = require 'co'

describe 'oauth2', ->

  oauth2 = null
  token = null

  before ->
    {oauth2} = sails.config

  it 'getToken', -> 
    co oauth2.getToken oauth2
      .then (token) ->
        oauth2.token = token
        console.log token

  it 'verify token', ->
    co oauth2.verify _.pick(oauth2, 'url', 'scope', 'token')

  it 'verify null', ->
    co oauth2.verify _.pick(oauth2, 'url', 'scope')
      .then Promise.reject
      .catch (err) ->
         Promise.resolve()

  it 'validToken', ->
    co oauth2.validToken oauth2
      .then console.log
