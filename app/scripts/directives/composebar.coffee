'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composebar', ($firebaseSimpleLogin, $rootScope, $window, Message) ->
    templateUrl: 'views/partials/composebar.html'
    restrict: 'E'
    scope: 
      channel: '='
    link: (scope, element, attrs) ->

      # Send a message
      scope.send = ->
        # Is there anything here?
        if scope.messageText
          Message.text scope.messageText, scope.channel
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

      # Grab focus when window comes into focus
      win = angular.element $window
      win.on 'focus', ->
        console.log 'regained focus, setting to compose'
        $rootScope.$broadcast 'focusOn', 'compose'

  )
