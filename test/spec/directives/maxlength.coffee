'use strict'

describe 'Directive: maxLength', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<max-length></max-length>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the maxLength directive'
