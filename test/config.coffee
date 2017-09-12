module.exports =
  oauth2:
    url:
      verify: 'https://abc.com/auth/oauth2/verify/'
      token: 'https://abc.com/auth/oauth2/token/'
    client:
      id: 'client id'
      secret: 'client secret'
    user:
      id: 'user id'
      secret: 'user secret'
    scope: [
      'User'
    ]
  proxy:
    url: 'https://abc.com/upstream' # for testing only
