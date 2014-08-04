'use strict'

describe 'Filter: parseUrl', ->

  # load the filter's module
  beforeEach module 'shortwaveApp'

  # initialize a new instance of the filter before each test
  parseUrl = {}
  beforeEach inject ($filter) ->
    parseUrl = $filter 'parseUrl'

  it 'should return the input prefixed with "parseUrl filter:"', ->
    text = 'angularjs'
    expect(parseUrl text).toBe ('parseUrl filter: ' + text)
