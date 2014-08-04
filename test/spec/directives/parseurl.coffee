'use strict'

describe 'Directive: parseUrl', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<parse-url></parse-url>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the parseUrl directive'
