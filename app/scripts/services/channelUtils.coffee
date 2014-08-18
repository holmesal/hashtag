'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.Channels
 # @description
 # # Channel
 # This service is responsible for fetching channel objects from firebase.
 # Primarily, it will be used in the route resolver - route changes won't proceed if the channel doesn't exist.
###
angular.module('shortwaveApp')
  .service 'ChannelUtils', ($firebase, $q, $rootScope, $timeout, User) ->
    

    ChannelUtils = 

        getChannel: (channelName) ->

            # Return a promise for route resolves
            deferredChannel = $q.defer()

            # Attempt to get the channel from firebase
            # (strip the hash if necessary)
            # if channelName[0] is '#'
            #   channelName = channel

            channelRef = new Firebase "#{$rootScope.firebaseURL}/channels/#{channelName}"

            channelRef.once 'value', (snap) ->
                channel = snap.val()

                if channel
                    deferredChannel.resolve 
                        data: channel
                        name: channelName
                        snap: snap
                else
                    deferredChannel.reject 'no channel exists'

            , (err) ->
                deferredChannel.reject err

            # Send the promise back!
            deferredChannel.promise

        createChannel: (channelName, description) ->

            deferredChannel = $q.defer()

            newChannel = 
                members: {}
                moderators: {}
                meta:
                    public: true
                    description: description

            authUser = User.getAuthUser()
            user = User.getUser()

            newChannel.members["#{authUser.uid}"] = true
            newChannel.moderators["#{authUser.uid}"] = true

            newChannelRef = $rootScope.rootRef.child "channels/#{channelName}"
            newChannelRef.set newChannel, (err) ->
                if err
                    # Trubbles!
                    deferredChannel.reject err
                else
                    # Worked!
                    # Now set the channel on yourself
                    channelListItemRef = $rootScope.rootRef.child "users/#{user.$id}/channels/#{channelName}"
                    channelListItemRef.setWithPriority
                        lastSeen: 0
                        muted: false
                    , Date.now(), (err) ->
                        if err
                            deferredChannel.reject err
                        else
                            deferredChannel.resolve()

            # Send back the promise
            deferredChannel.promise

        joinChannel: (channelName) ->

            joined = $q.defer()

            authUser = User.getAuthUser()
            user = User.getUser()

            # Only proceed if you're not already in this channel
            unless user.channels?[channelName]

                # Add yourself to the channel members
                channelMemberRef = $rootScope.rootRef.child "channels/#{channelName}/members/#{authUser.uid}"
                channelMemberRef.set true, (err) ->
                    debugger
                    if err
                        joined.reject err
                    else
                        console.log 'joined ok!'
                        selfChannelRef = $rootScope.rootRef.child "users/#{user.$id}/channels/#{channelName}"
                        selfChannelRef.setWithPriority
                            lastSeen: 0
                            muted: false
                        , Date.now(), (err) ->
                            if err
                                joined.reject err
                            else
                                joined.resolve()

            # Otherwise, just pretend you joined (sshhhhh)
            else
                console.warn 'faking join for a channel you are already in'
                # Behold: the sketchy way to resolve a promise just after returning it
                $timeout joined.resolve, 0

            joined.promise

        checkChannel: (channelName) ->

            console.log "checking channel #{channelName}"

            exists = $q.defer()

            # make the channel ref
            publicRef = $rootScope.rootRef.child "channels/#{channelName}/meta"
            publicRef.once 'value', (snap) ->
                console.log "Channel public value is #{snap.val()?.public}"
                if snap.val()
                    exists.resolve
                        channelName: channelName
                        exists: true
                        meta: snap.val()
                else
                    exists.resolve
                        channelName: channelName
                        exists: false
                        meta: null
            , (err) ->
                exists.reject
                    error: err
                    channelName: channelName


            exists.promise


        setMute: (channelName, value) ->

            set = $q.defer()

            user = User.getUser()

            muteRef = user.$getRef().child "channels/#{channelName}/muted"
            muteRef.set value, (err) ->
                if err
                    set.reject err
                else
                    set.resolve()

            set.promise

        leaveChannel: (channelName) ->

            left = $q.defer()

            authUser = User.getAuthUser()
            user = User.getUser()

            # First, remove yourself from the members of the channel
            memberRef = $rootScope.rootRef.child "/channels/#{channelName}/members/#{authUser.uid}"
            memberRef.set null, (err) ->
                if err
                    left.reject()
                else

                    # Then, remove the channel from your own list
                    listRef = $rootScope.rootRef.child "users/#{user.$id}/channels/#{channelName}"
                    listRef.set null, (err) ->
                        if err
                            left.reject()
                        else
                            left.resolve()


            left.promise

