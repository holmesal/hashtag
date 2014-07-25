'use strict'

describe 'Directive: channelListItem', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<channel-list-item></channel-list-item>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the channelListItem directive'
