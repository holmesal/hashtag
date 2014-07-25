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
  .service 'ChannelUtils', ($firebase, $q, $rootScope, User) ->
    

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
                    deferredChannel.resolve channel
                else
                    deferredChannel.reject 'no channel exists'

            , (err) ->
                deferredChannel.reject err

            # Send the promise back!
            deferredChannel.promise

        createChannel: (channelName) ->

            deferredChannel = $q.defer()

            unless channelName
                console.error 'must pass a channel name'
                return

            newChannel = 
                members: {}
                moderators: {}
                public: true

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
                    channelListItemRef = user.$getRef().child('channels').child channelName
                    channelListItemRef.setWithPriority
                        lastSeen: 0
                    , Date.now(), (err) ->
                        if err
                            deferredChannel.reject err
                        else
                            deferredChannel.resolve()

            # Send back the promise
            deferredChannel.promise


