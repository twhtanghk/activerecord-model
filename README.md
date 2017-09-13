# activerecord-model
Async [ActiveRerord](https://bfanger.nl/angular-activerecord/api/#!/api/ActiveRecord) like [StampIT](https://github.com/stampit-org/stampit) Model for Rest API

## Install
```
npm install activerecord-model
```

## [API](https://rawcdn.githack.com/twhtanghk/activerecord-model/master/docs/index.html)

## Example
```
{async, await} = require 'asyncawait'
{token, validToken, authApi, model} = require 'activerecord-model'

async ->
  Proxy = model 'http://host/upstream'
    .use authApi async ->
      opts =
        getToken: async ->
          await token opts
        url:
          token: 'http://tokenUrl'
          verify: 'http://verifyUrl'
        client:
          id: 'client id'
          secret: 'client secret'
        user:
          id: 'user id'
          secret: 'user secret'
        scope: [ 'User' ]
      await validToken opts
  proxy = new Proxy
    name: 'test'
    prefix: '/test/'
    target: 'http://192.168.1.1'
  await proxy.save()
```
