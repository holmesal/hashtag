'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:stream
 # @description
 # # stream
###
angular.module('shortwaveApp')
  .directive('stream', ($rootScope, $firebase) ->
    templateUrl: 'views/partials/stream.html'
    restrict: 'E'
    scope:
      channel: '='
    link: (scope, element, attrs) ->
      
      scope.$watch 'channel', (up) ->
        console.log 'channel changed to ' + up
        if scope.channel

          # Get the new ref
          messagesRef = $rootScope.rootRef.child "messages/#{scope.channel}"
          sync = $firebase messagesRef

          scope.messages = sync.$asArray()

          scope.messages.$loaded().then ->
            console.log "messages were loaded woohoo!"






  )
