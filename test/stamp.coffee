_ = require 'lodash'
{token, verify, validToken, authApi, model} = require '../index'
config = require './config.coffee'
{async, await} = require 'asyncawait'

describe 'stamp', ->
  opts = _.extend config.oauth2, getToken: async ->
    await token opts

  it 'token', async ->
    await opts.getToken()

  it 'verify', async ->
    await verify _.extend token: await(opts.getToken()), _.pick(opts, 'url', 'scope')
    
  it 'validToken', async ->
    await validToken opts

  it 'authApi', async ->
    authApi async ->
      await validToken opts

  it 'proxy', async ->
    Proxy = model config.proxy.url
      .use authApi async ->
        await validToken opts
    proxy = new Proxy
      name: 'test'
      prefix: '/test/'
      target: 'http://192.168.1.1'
    await proxy.save()
