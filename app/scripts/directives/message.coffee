'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:message
 # @description
 # # message
###
angular.module('shortwaveApp')
  .directive('message', ($rootScope, $firebase) ->
    templateUrl: 'views/partials/message.html'
    restrict: 'E'
    scope:
      message: '='
    link: (scope, element, attrs) ->

      console.log scope.message

      ownerRef = $rootScope.rootRef.child "users/#{scope.message.owner}/profile"
      scope.owner = $firebase ownerRef
  )
