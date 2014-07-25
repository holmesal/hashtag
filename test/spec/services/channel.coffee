'use strict'

describe 'Service: ChannelUtils', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  ChannelUtils = {}
  beforeEach inject (_ChannelUtils_) ->
    ChannelUtils = _ChannelUtils_

  it 'should do something', ->
    expect(!!ChannelUtils).toBe true
