'use strict'

describe 'Service: message', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  message = {}
  beforeEach inject (_message_) ->
    message = _message_

  it 'should do something', ->
    expect(!!message).toBe true
