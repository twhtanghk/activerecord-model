co = require 'co'

describe 'proxy', ->
  Proxy = null
  proxy = null

  before ->
    Proxy = sails.config.proxy.model()

  it 'create', ->
    proxy = new Proxy
      name: 'test'
      prefix: '/test/'
      target: 'http://192.168.1.1'
    co proxy.save()

  it 'destroy', ->
    co proxy.destroy()

  it 'fetchAll', ->
    co Proxy.fetchAll()
      .then (gen) ->
        for i from gen()
          console.log i
