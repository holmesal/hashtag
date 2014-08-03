'use strict'

describe 'Directive: channelList', ->

  # load the directive's module
  beforeEach module 'shortwaveApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<channel-list></channel-list>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the channelList directive'
