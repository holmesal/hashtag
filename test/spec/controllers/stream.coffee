'use strict'

describe 'Controller: StreamCtrl', ->

  # load the controller's module
  beforeEach module 'shortwaveApp'

  StreamCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    StreamCtrl = $controller 'StreamCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
