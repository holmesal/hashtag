'use strict'

describe 'Directive: focusOn', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<focus-on></focus-on>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the focusOn directive'
