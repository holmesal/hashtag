'use strict'

describe 'Service: NodeWebkit', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  NodeWebkit = {}
  beforeEach inject (_NodeWebkit_) ->
    NodeWebkit = _NodeWebkit_

  it 'should do something', ->
    expect(!!NodeWebkit).toBe true
