'use strict'

describe 'Controller: InviteCtrl', ->

  # load the controller's module
  beforeEach module 'shortwaveApp'

  InviteCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    InviteCtrl = $controller 'InviteCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
