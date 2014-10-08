'use strict'

describe 'Service: version', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  version = {}
  beforeEach inject (_version_) ->
    version = _version_

  it 'should do something', ->
    expect(!!version).toBe true
