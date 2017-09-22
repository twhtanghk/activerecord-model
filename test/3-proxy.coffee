co = require 'co'
require '../index'

describe 'proxy', ->
  Proxy = arModel.proxy.model()
  proxy = null

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
