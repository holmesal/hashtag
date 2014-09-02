'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.channels
 # @description
 # # channels
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Channels', ($rootScope, $firebase, $timeout, $filter, User) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    class Channels

      constructor: ->

        @messages = {}
        @unread = {}

        # Wait for the user to exist
        User.get().then (user) =>
            @user = user

            # Watch the user's list of channels
            channelListRef = $rootScope.rootRef.child "users/#{@user.$id}/channels"

            sync = $firebase channelListRef

            @channelList = sync.$asArray()
            @channels = sync.$asObject()

            @loaded = @channelList.$loaded()

            # When the list of channels changes, we'll want to look for new ones
            @channelList.$watch @channelListChanged, @

      channelListChanged: (wat) ->
        console.info 'channel list item changed', wat
        console.log @channelList

        keys = []

        name = wat.key

        if wat.event is 'child_added'
            console.info "setting up channel: #{name}"
            ref = $rootScope.rootRef.child "messages/#{name}"
            sync = $firebase ref.limit(50)
            @messages[name] = sync.$asArray()
            # Once this list of messages loads, start watching it
            @messages[name].$loaded().then =>
                # Check the unread notifications right away
                console.log "pre-checking times for #{name}"
                @checkTimes name
                # When this list of messages changes, check the newest times
                # And broadcast a "got message" event
                @messages[name].$watch (message) =>
                    @checkTimes name
                    @sendNotification name, message

        else if wat.event is 'child_changed'
            console.info "channel updated: #{name}"
            @checkTimes name

        else if wat.event is 'child_removed'
            console.info "deleting channel: #{name}"
            delete @messages[name]


      checkTimes: (name) ->
        console.warn "checking times for channel #{name}"
        # console.log @channelList
        chan = @channelList.$getRecord(name)
        lastSeen = chan?.lastSeen
        # Calc unread
        unreadCount = 0
        newestTime = 0
        for message in @messages[name]
            if message.$priority > lastSeen #and @user.viewing isnt name and message.owner isnt @user.$id
                unreadCount += 1
                newestTime = message.$priority
            if message.$priority > newestTime
                newestTime = message.$priority

        chan.unreadCount = unreadCount
        chan.newestTime = newestTime


      sendNotification: (channelName, ev) ->
        # Only respond to messages being added
        if ev.event is 'child_added'
            idx = @messages[channelName].$indexFor ev.key
            message = @messages[channelName][idx]
            console.log "new message: #{message.content.text}"

            # If this isn't in your list of channels to ignore
            console.log "is muted? #{@user.channels[channelName]?.muted}"
            unless @user.channels[channelName]?.muted
                # If this isn't you and this isn't a parsed message
                # console.log "is this a parsed message? #{message.parsedFrom}"
                if @user.$id isnt message.owner and not message.parsedFrom
                    # Grab the owner's name
                    nameRef = $rootScope.rootRef.child "users/#{message.owner}/profile/firstName"
                    nameRef.once 'value', (snap) ->
                        name = snap.val()
                        console.log 'sending notification'
                        # Create and send a new notification
                        Notification.requestPermission()
                        note = new Notification "#{name} (##{channelName})",
                            icon: 'images/icon.png'
                            body: message.content.text
                            tag: ev.key



    return new Channels
