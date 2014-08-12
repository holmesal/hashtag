'use strict'

describe 'Directive: safeChannelName', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<safe-channel-name></safe-channel-name>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the safeChannelName directive'
