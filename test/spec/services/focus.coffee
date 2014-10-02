'use strict'

describe 'Service: focus', ->

  # load the service's module
  beforeEach module 'shortwaveApp'

  # instantiate service
  focus = {}
  beforeEach inject (_focus_) ->
    focus = _focus_

  it 'should do something', ->
    expect(!!focus).toBe true
