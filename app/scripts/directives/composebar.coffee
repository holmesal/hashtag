'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composebar', ($firebaseSimpleLogin, $rootScope, Message) ->
    templateUrl: 'views/partials/composebar.html'
    restrict: 'E'
    scope: 
      channel: '='
    link: (scope, element, attrs) ->

      # Send a message
      scope.send = ->
        # Is there anything here?
        if scope.messageText
          Message.send scope.channel, scope.messageText
          .then ->
            console.log "send message successfully"
          .catch (err) ->
            console.error "error sending message"
            console.error err
            # restore the old text
            scope.messageText = scope.lastText

          # store the last text
          scope.lastText = scope.messageText
          # Clear the current text
          scope.messageText = ''

      scope.keydown = (ev) ->

        if ev.keyCode is 13
          scope.send()

  )
