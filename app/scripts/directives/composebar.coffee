'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composebar', ($firebaseSimpleLogin, $rootScope, $window, $timeout, $firebase, Message) ->
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
        # console.log "height changed to #{height}px"
        scope.composeHeight = "#{height}px"
        # Broadcast a change in height
        $rootScope.$broadcast 'heightUpdate'

      # Send a message
      scope.send = ->
        # Is there anything here?
        if scope.messageText
          # build the @mentions array
          mentions = []
          for uuid,mentionString of scope.mentions 
            mentions.push
              uuid: uuid
              substring: mentionString

          # Replace with line breaks
          text = scope.messageText.replace '\n','</br>'
          Message.text text, scope.channelName, mentions
          .then ->
            # console.log "send message successfully"
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
        # console.info "keypress: #{ev.keyCode}"

        # Enter key sends unless
        # 1. you hold down shift (newline instead)
        # 2. the autocomplete is open (selects current index)
        if ev.keyCode is 13
          # Is the autocomplete open?
          if scope.query
            scope.$broadcast 'autocomplete:select'
            ev.preventDefault()
          else
            # Is shift being held down?
            unless ev.shiftKey
              scope.send()

        # Up/down arrow keys are ignored if the autocomplete is open
        if ev.keyCode in [38,40] and scope.query
          direction = if ev.keyCode is 38 then 'up' else 'down'
          # Pass this along to the autocomplete
          scope.$broadcast 'autocomplete:move', direction
          # Ignore in the textarea
          ev.preventDefault()

        # Escape key closes the autocomplete
        if ev.keyCode is 27
          scope.query = null


      # Grab focus when window comes into focus
      win = angular.element $window
      win.on 'focus', ->
        # console.log 'regained focus, setting to compose'
        $rootScope.$broadcast 'focusOn', 'compose'


      # Every time the text changes, check it for stuffs
      scope.$watch 'messageText', (text) ->

        scope.query = null
        scope.mentions = {}

        if text

          # Show the autocomplete if we're inside an @mention
          lastAt = text.lastIndexOf '@'
          if lastAt != -1
            lastSpace = text.lastIndexOf ' '
            # If there's no space after the at, the query is what's in between
            unless lastSpace > lastAt
              scope.query = 
                atPosition: lastAt
                text: text.substring lastAt, text.length


          # Compute the mentions object
          mentionStrings = text.match /\B\@([\w\-]+)/gim
          # console.log mentionStrings
          # For each mention string, try to match it with a user
          for mentionString in mentionStrings or []
            # Strip off the @
            mentionString = mentionString.replace '@', ''
            # Go through each user in this channel
            for member in scope.members
              memberName = "#{member.profile.firstName}#{member.profile.lastName}"
              if mentionString.toLowerCase() is memberName.toLowerCase()
                # This is a match
                # console.log "@#{mentionString} ---> #{member.$id}"
                scope.mentions[member.$id] = mentionString


      # Watch for changes to the channel
      scope.$watch 'channelName', (chan) ->
        if chan
          # Clear any existing members references
          if scope.members 
            scope.members.$destroy()

          # Set up a firebase referece to the members of this channel
          membersRef = $rootScope.rootRef.child "channels/#{scope.channelName}/members"
          sync = $firebase membersRef
          scope.members = sync.$asArray()

          # Watch for new members being added
          scope.members.$watch (ev) ->
            if ev.event is 'child_added'
              # console.log "new child added! #{ev.key}"
              # Grab this user's profile
              profileRef = $rootScope.rootRef.child "users/#{ev.key}/profile"
              sync = $firebase profileRef
              # Store this in the members array
              member = scope.members.$getRecord ev.key
              member.profile = sync.$asObject()

      scope.completeMention = (mentionString) ->
        # Render the text in place of what's already there
        # First trim the existing string
        scope.messageText = scope.messageText.substring 0, scope.query.atPosition + 1

        # Add the text returned from the autocomplete, and a space
        scope.messageText += "#{mentionString} "

  )
