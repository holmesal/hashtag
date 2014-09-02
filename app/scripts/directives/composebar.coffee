'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composebar', ($firebaseSimpleLogin, $rootScope, $window, $timeout, Message) ->
    templateUrl: 'views/partials/composebar.html'
    restrict: 'E'
    scope: 
      channel: '='
      uploader: '='
      composeHeight: '='
    link: (scope, element, attrs) ->

      # Get the height straightaway
      # alert element.height()

      scope.$watch ->
        element.height()
      , (height) ->
        console.log "height changed to #{height}px"
        scope.composeHeight = "#{height}px"

      # Send a message
      scope.send = ->
        # Is there anything here?
        if scope.messageText
          # Replace with line breaks
          text = scope.messageText.replace '\n','</br>'
          Message.text text, scope.channel
          .then ->
            console.log "send message successfully"
            # Bump the last-seen time
            $rootScope.$broadcast 'bumpTime', scope.channel
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
          # Is shift being held down?
          unless ev.shiftKey
            scope.send()

      # Grab focus when window comes into focus
      win = angular.element $window
      win.on 'focus', ->
        console.log 'regained focus, setting to compose'
        $rootScope.$broadcast 'focusOn', 'compose'

  )
