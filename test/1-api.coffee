co = require 'co'
util = require 'util'
assert = require 'assert'
require '../index'

describe 'api', ->

  {api, oauth2} = arModel

  it 'post', -> co ->
    {url, client, user, scope} = oauth2
    opts =
      'Content-Type': 'application/x-www-form-urlencoded'
      username: client.id
      password: client.secret
    data =
      grant_type: 'password'
      username: user.id
      password: user.secret
      scope: scope.join(' ')
    {statusCode, statusMessage, body} = yield api().post url.token, data, opts
    assert statusCode == 200 and not body.error?, "#{statusMessage}: #{util.inspect body}"
    console.log body.access_token

###
  it 'get', ->
    co api().get oauth2.url.token
      .then (res) ->
        console.log res
###
