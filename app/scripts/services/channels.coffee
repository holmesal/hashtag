'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.channels
 # @description
 # # channels
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Channels', ($rootScope, $firebase, $timeout, $interval, $filter, Focus, User, Analytics) ->
    # AngularJS will instantiate a singleton by calling "new" on this function
    # 
    

    # Every time a channel is set up, start listening to the channel meta
    # Every time the remote lastSeenTime updates, update your own channel priority
    # An unread channel is just one where those two things are out of sync


    class Channels

      constructor: ->

        # @messages = {}
        # @unread = {}  

        # Wait for the user to exist
        User.get().then (user) =>
            @user = user

            # Watch the user's list of channels
            channelListRef = $rootScope.rootRef.child "users/#{@user.$id}/channels"

            sync = $firebase channelListRef

            @channels = sync.$asArray()

            @loaded = @channels.$loaded()

            # Once the channel list loads, store the length
            @channels.$loaded().then (chans) =>
              # Track the number of channels this user is in
              Analytics.identify @user.$id,
                channelCount: chans.length

            # When the list of channels changes, we'll want to look for new ones
            @channels.$watch @channelListChanged, @

            # When the viewing changes remotely, update the current channel
            viewingRef = $rootScope.rootRef.child "users/#{@user.$id}/viewing"
            viewingRef.on 'value', (snap) ->
              if snap.val()
                $rootScope.$broadcast 'updateChannel', snap.val()



      channelListChanged: (wat) ->
        # console.info 'channel list item changed', wat
        # console.log @channelList

        # keys = []

        # name = wat.key

        if wat.event is 'child_added'
            # Start to watch this channel for latestMessagePriority changes
            # console.info "starting to watch channel #{wat.key}"
            ref = $rootScope.rootRef.child "channels/#{wat.key}/meta/latestMessagePriority"
            ref.on 'value', (snap) =>
                time = snap.val()
                # console.info "updating personal .priority for channel #{wat.key} -> #{time}"
                chanRef = $rootScope.rootRef.child "users/#{@user.$id}/channels/#{wat.key}"
                chanRef.setPriority time

            # Start watching just the newest message on this channel
            ref = $rootScope.rootRef.child("messages/#{wat.key}").limit(1)
            # ref.on 'child_added', (snap) ->
            #   console.info 'message added', snap.val()
            sync = $firebase(ref).$asArray()
            sync.$loaded().then =>
              sync.$watch (ev) =>
                if ev.event is 'child_added'
                  # New message added, send a notification
                  @notify wat.key, sync[0]
                  # console.log 'new message added!', sync[0]
            # chan = @channels.$getRecord wat.key
            # chan.$lastMessage = sync.$asArray()
            # console.info 'channel created', chan

        # else if wat.event is 'child_changed'
        #     console.info "channel updated: #{name}"
        #     console.info @channels.$getRecord(wat.key)

        else if wat.event is 'child_removed'
            console.info "deleting channel: #{name}"
            # delete @messages[name]
            ref = $rootScope.rootRef.child "channels/#{wat.key}/meta/latestMessagePriority"
            ref.off()


      # checkTimes: (name) ->
      #   console.warn "checking times for channel #{name}"
      #   # console.log @channelList
      #   chan = @channelList.$getRecord(name)
      #   lastSeen = chan?.lastSeen
      #   # Calc unread
      #   unreadCount = 0
      #   newestTime = 0
      #   for message in @messages[name]
      #       if message.$priority > lastSeen #and @user.viewing isnt name and message.owner isnt @user.$id
      #           unreadCount += 1
      #           newestTime = message.$priority
      #       if message.$priority > newestTime
      #           newestTime = message.$priority

      #   chan.unreadCount = unreadCount
      #   chan.newestTime = newestTime


      notify: (channelName, message) ->
        # Always send if you're in the @mentions
        if message.mentions
          mentioned = (mention for mention in message.mentions when mention.uuid is @user.$id)
          console.log "computed mentions"
          console.log mentioned
          if mentioned.length > 0
            @showNotification channelName, message

        # Otherwise, lots of reasons to not send a push notificiation
        else
          # Have you muted the channel?
          unless @user.channels[channelName]?.muted
              # Did you send this message?
              unless @user.$id is message.owner
                # Is this a parsed message?
                unless message.parsedFrom
                  # Is this in a channel hidden from you, or is the app in the background?
                  if channelName isnt @user.viewing or not Focus.focus
                    # Ok fine, send the message
                    @showNotification channelName, message
                  

      showNotification: (channelName, message) ->
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
                tag: message.$id



    return new Channels
