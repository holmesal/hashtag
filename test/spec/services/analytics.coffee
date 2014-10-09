'use strict'

describe 'Service: analytics', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  analytics = {}
  beforeEach inject (_analytics_) ->
    analytics = _analytics_

  it 'should do something', ->
    expect(!!analytics).toBe true
