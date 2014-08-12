'use strict'

describe 'Filter: channelName', ->

  # load the filter's module
  beforeEach module 'shortwaveApp'

  # initialize a new instance of the filter before each test
  channelName = {}
  beforeEach inject ($filter) ->
    channelName = $filter 'channelName'

  it 'should return the input prefixed with "channelName filter:"', ->
    text = 'angularjs'
    expect(channelName text).toBe ('channelName filter: ' + text)
