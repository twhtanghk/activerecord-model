# activerecord-model
Async [ActiveRerord](https://bfanger.nl/angular-activerecord/api/#!/api/ActiveRecord) like [StampIT](https://github.com/stampit-org/stampit) Model for Rest API

## Install
```
npm install activerecord-model
```

## [API](https://rawcdn.githack.com/twhtanghk/activerecord-model/master/docs/index.html)

## Example
```
_ = require 'lodash'
_.defaults = require 'merge-defaults'
co = require 'co'

global.sails = 
  config: require './config/env/production.coffee'

_.defaults sails.config, require 'activerecord-model'

Proxy = sails.config
  .armodel sails.config.proxy.url
  .use sails.config.api().use sails.config.oauth2.getOpts
proxy = new Proxy
  name: 'test'
  prefix: '/test/'
  target: 'http://192.168.1.1'
co proxy.save()

```
