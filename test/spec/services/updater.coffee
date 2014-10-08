'use strict'

describe 'Service: updater', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  updater = {}
  beforeEach inject (_updater_) ->
    updater = _updater_

  it 'should do something', ->
    expect(!!updater).toBe true
