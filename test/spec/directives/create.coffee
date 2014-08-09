'use strict'

describe 'Directive: create', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<create></create>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the create directive'
