'use strict'

describe 'Service: channels', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  channels = {}
  beforeEach inject (_channels_) ->
    channels = _channels_

  it 'should do something', ->
    expect(!!channels).toBe true
