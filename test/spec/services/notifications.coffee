'use strict'

describe 'Service: notifications', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  notifications = {}
  beforeEach inject (_notifications_) ->
    notifications = _notifications_

  it 'should do something', ->
    expect(!!notifications).toBe true
