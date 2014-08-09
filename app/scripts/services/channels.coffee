'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.channels
 # @description
 # # channels
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Channels', ($rootScope, $firebase, $timeout, User, Notifications) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    class Channels

      constructor: ->

        @messages = {}
        @unread = {}

        # Just naively assume a user already exists
        @user = User.getUser()

        # Watch the user's list of channels
        channelListRef = $rootScope.rootRef.child "users/#{@user.$id}/channels"

        sync = $firebase channelListRef

        @channelList = sync.$asArray()
        @channels = sync.$asObject()

        @loaded = @channelList.$loaded()

        # When the list of channels changes, we'll want to look for new ones
        @channelList.$watch @channelListChanged, @

      #   # Once the list of channels is loaded, load the messages
      #   @loaded.then @loadMessages

      # loadMessages: ->
      #   # For each channel, set up a corresponding sync ref for the messages in that channel
      #   console.log 'would be loading messages here'

      channelListChanged: ->
        # console.log 'the list of channels changed:'
        # console.log @channelList

        keys = []

        # Go through the channels, and make sure you've got a listener for that channel set up
        for channel in @channelList
            name = channel.$id
            keys.push name
            unless @messages[name]
                console.log "(setting up channel #{name})"
                ref = $rootScope.rootRef.child "messages/#{name}"
                sync = $firebase ref.limit(50)
                @messages[name] = sync.$asArray()

                # Once this list of messages loads, start watching it
                @messages[name].$loaded().then =>
                    # When this list of messages changes, check the newest times
                    # And broadcast a "got message" event
                    @messages[name].$watch (message) =>
                        @checkTimes name
                        @sendNotification name, message

        # Remove any channels locally that aren't in the updated list
        for name, channel of @messages
            unless name in keys
                console.log "deleting channel #{name}"
                delete @messages[name]

        # console.log "udpated channels: "
        # console.log @messages

      checkTimes: (name) ->
        # console.warn "checking times for channel #{name}"
        # Get the priority of the last message
        latest = @messages[name][@messages[name].length - 1].$priority
        # Is the last message newer?
        for channelName, idx in @channelList
            if channelName.$id is name
                if latest > @channelList[idx].lastSeen
                    @channelList[idx].unread = true
                    # console.warn "got a newer message!"

      sendNotification: (channelName, ev) ->
        # Only respond to messages being added
        if ev.event is 'child_added'
            idx = @messages[channelName].$indexFor ev.key
            message = @messages[channelName][idx]
            console.log "new message: #{message.content.text}"

            # Create and send a new notification
            Notification.requestPermission()
            note = new Notification "##{channelName}: #{message.content.text}",
                icon: './images/yeoman.png'
                body: message.content.text
                tag: ev.key



    return new Channels
