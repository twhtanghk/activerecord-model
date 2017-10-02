    _ = require 'lodash'
    assert = require 'assert'
    util = require 'util'
    co = require 'co'

    module.exports =
      oauth2:
        url:

Authorization URL to seek user authorization

          authorize: 'https://abc.com/auth/oauth2/authorize/'

URL for verifying token

          verify: 'https://abc.com/auth/oauth2/verify/'

URL for acquiring token

          token: 'https://abc.com/auth/oauth2/token/'

        client:

client id for resource owner password credential grant or client credential grant

          id: 'client_id'

client secret for resource owner password credential grant or client credential grant

          secret: 'client_secret'

        user:

user id for acquiring token via resource owner password credential grant

          id: 'user_id'

user secret for acquireing token via resource owner password credential grant

          secret: 'user_secret'

required scope for user to authorize or verifying token

        scope: [
          'User'
        ]

acquire token for resource owner password credentials grant from oauth2 server
```
opts:
  url: 
    token: url to acquire token
  client:
    id: client id
    secret: client secret
  user:
    user: user id
    secret: user secret
  scope: [
    'User'
   ...
  ]
```

        getToken: (opts) ->
          {url, client, user, scope} = opts
          opts =
            'Content-Type': 'application/x-www-form-urlencoded'
            username: client.id
            password: client.secret
          data = {}
          if user?
            data =
              grant_type: 'password'
              username: user.id
              password: user.secret
              scope: scope.join(' ')
          else
            data =
              grant_type: 'client_credentials'
          api = sails.config.api()
          res = yield api.post url.token, data, opts
          api.ok res, 200
          res.body.access_token

verify token with input url
```
opts:
  url:
    verify: url to verify token
  scope: [
    'User'
    ...
  ]
  token: token to be verified
```

        verify: (opts) ->
          {url, scope, token} = opts
          opts =
            headers:
              Authorization: "Bearer #{token}"
          api = sails.config.api()
          res = yield api.get(url.verify, null, opts)
          api.ok res, 200
          result = _.intersection scope, res.body.scope.split(' ')
          assert result.length == scope.length, "Unauthorizated access to #{scope}"
          res.body 

function to acquire token even if expired
```
opts:
  getToken: function to acquire token
  url:
    verify: url to verify token
  scope: [
    'User'
    ...
  ]
```

        validToken: (opts) ->
          cond = ->
            not opts.token
          action = -> co ->
            while true
              {token, getToken, url, scope} = opts
              try
                verified = yield module.exports.oauth2.verify opts
                return opts.token
              catch err
                opts.token = yield getToken opts
          yield sails.config.Promise.until cond, action
            .then ->
              opts.token

return customized opts with oauth2 bearer

        getOpts: (opts) ->
          ret =
            rejectUnauthorized: false
            headers:
              Authorization: "Bearer #{yield module.exports.oauth2.validToken sails.config.oauth2}"
          _.extend ret, opts

