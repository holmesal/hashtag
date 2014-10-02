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
      channelName: '='
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
        # Broadcast a change in height
        $rootScope.$broadcast 'heightUpdate'

      # Send a message
      scope.send = ->
        # Is there anything here?
        if scope.messageText
          # Replace with line breaks
          text = scope.messageText.replace '\n','</br>'
          Message.text text, scope.channelName
          .then ->
            console.log "send message successfully"
            # Bump the last-seen time
            $rootScope.$broadcast 'bumpTime', scope.channelName
          .catch (err) ->
            console.error "error sending message"
            console.error err
            # restore the old text
            scope.messageText = scope.lastText

          # store the last text
          scope.lastText = scope.messageText

          # Clear the current text - but do it on the next digest
          $timeout -> # /hack
            scope.messageText = null

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


      # Every time the text changes, check it for stuffs
      scope.$watch 'messageText', (text) ->
        scope.query = null
        if text
          # Are we inside an @mention right now?
          lastAt = text.lastIndexOf '@'
          if lastAt != -1
            lastSpace = text.lastIndexOf ' '
            # If there's no space after the at, the query is what's in between
            unless lastSpace > lastAt
              scope.query = text.substring lastAt, text.length

  )
