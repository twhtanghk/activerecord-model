_ = require 'lodash'
rest = require '../index'
config = require './config.coffee'
{async, await} = require 'asyncawait'

describe 'stamp', ->
  token = null
  getToken = async ->
    await rest.token config.oauth2

  it 'token', async ->
    token = await rest.token config.oauth2

  it 'verify', async ->
    opts = _.extend token: token, _.pick(config.oauth2, 'url', 'scope')
    await rest.verify opts
    
  it 'validToken', async ->
    token = null
    token = await rest.validToken getToken, config.oauth2

  it 'authApi', async ->
    rest.authApi async ->
      await rest.validToken getToken, config.oauth2

  it 'proxy', async ->
    Proxy = rest.model config.proxy.url
    Proxy.use rest.authApi async ->
      await rest.validToken getToken, config.oauth2
    proxy = new Proxy
      name: 'test'
      prefix: '/test/'
      target: 'http://192.168.1.1'
    await proxy.save()
