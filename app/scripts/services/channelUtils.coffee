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
    

    class ChannelUtils

        constructor: ->
            # Once the user logs in, check the channels and autojoin if necessary
            $rootScope.$on 'userLoaded', (ev, user) =>
                console.info "channel utils saw user load", user
                # Check if this is a new user
                unless user.channels
                    @autoJoin()

            # Listen for requests to update the lastSeen time of a channel
            $rootScope.$on 'bumpTime', (ev, channelName) =>
                console.log 'ok'
                @bumpTime channelName


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

            # Cast to string
            channelName = String channelName

            deferredChannel = $q.defer()

            newChannel = 
                members: {}
                moderators: {}
                meta:
                    public: true
                    description: if description then description else ""

            newChannel.members["#{User.user.$id}"] = true
            newChannel.moderators["#{User.user.$id}"] = true

            newChannelRef = $rootScope.rootRef.child "channels/#{channelName}"
            newChannelRef.set newChannel, (err) ->
                if err
                    # Trubbles!
                    deferredChannel.reject err
                else
                    # Worked!
                    console.log 'setting channel on self'
                    # Now set the channel on yourself
                    channelListItemRef = $rootScope.rootRef.child "users/#{User.user.$id}/channels/#{channelName}"
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

            # Only proceed if you're not already in this channel
            unless User.user.channels?[channelName]

                # Add yourself to the channel members
                channelMemberRef = $rootScope.rootRef.child "channels/#{channelName}/members/#{User.user.$id}"
                channelMemberRef.set true, (err) ->
                    if err
                        joined.reject err
                    else
                        console.log 'joined ok!'
                        selfChannelRef = $rootScope.rootRef.child "users/#{User.user.$id}/channels/#{channelName}"
                        selfChannelRef.setWithPriority
                            lastSeen: 0
                            muted: false
                        , Date.now(), (err) ->
                            if err
                                joined.reject err
                            else
                                joined.resolve channelName

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

            muteRef = $rootScope.rootRef.child "users/#{User.user.$id}/channels/#{channelName}/muted"
            muteRef.set value, (err) ->
                if err
                    set.reject err
                else
                    set.resolve()

            set.promise

        leaveChannel: (channelName) ->

            left = $q.defer()

            # First, remove yourself from the members of the channel
            memberRef = $rootScope.rootRef.child "/channels/#{channelName}/members/#{User.user.$id}"
            memberRef.set null, (err) ->
                if err
                    left.reject()
                else

                    # Then, remove the channel from your own list
                    listRef = $rootScope.rootRef.child "users/#{User.user.$id}/channels/#{channelName}"
                    listRef.set null, (err) ->
                        if err
                            left.reject()
                        else
                            left.resolve()


            left.promise

        setViewing: (channelName) ->

            set = $q.defer()

            viewRef = $rootScope.rootRef.child "users/#{User.user.$id}/viewing"
            viewRef.set channelName, (err) ->
                if err
                    set.reject err
                else
                    set.resolve()

            set.promise

        bumpTime: (channelName) ->
            nowRef = $rootScope.rootRef.child "users/#{User.user.$id}/channels/#{channelName}/lastSeen"
            nowRef.set Date.now(), (err) ->
                if err
                    console.error err

        autoJoin: ->
            # Get the channels to be auto-joined
            chanRef = $rootScope.rootRef.child "static/defaultChannels"
            chanRef.once 'value', (chanSnap) =>
              chans = chanSnap.val()
              console.log chans

              for chan in chans
                @joinChannel chan 
                .then (channelName) ->
                  console.log "autoJoiner successfully joined channel #{channelName}"
                , (err) ->
                  console.error err

    return new ChannelUtils

