'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.channels
 # @description
 # # channels
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Channels', ($rootScope, $firebase, User) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    class Channels

      constructor: ->

        @channels = {}

        console.log 'making channels@'
        @channelList = 'hi!!!!'

        # Just naively assume a user already exists
        @user = User.getUser()

        # Watch the user's list of channels
        channelListRef = $rootScope.rootRef.child "users/#{@user.$id}/channels"

        sync = $firebase channelListRef

        @list = sync.$asArray()

        @loaded = @list.$loaded()

        # When the list of channels changes, we'll want to look for new ones
        @list.$watch @listChanged, @

      #   # Once the list of channels is loaded, load the messages
      #   @loaded.then @loadMessages

      # loadMessages: ->
      #   # For each channel, set up a corresponding sync ref for the messages in that channel
      #   console.log 'would be loading messages here'

      listChanged: ->
        console.log 'the list of channels changed:'
        console.log @list

        keys = []

        # Go through the channels, and make sure you've got a listener for that channel set up
        for channel in @list
            name = channel.$id
            keys.push name
            unless @channels[name]
                console.log "(setting up channel #{name})"
                ref = $rootScope.rootRef.child "messages/#{name}"
                sync = $firebase ref.limit(50)
                @channels[name] = sync.$asArray()

        # Remove any channels locally that aren't in the updated list
        for name, channel of @channels
            unless name in keys
                console.log "deleting channel #{name}"
                delete @channels[name]

        console.log "udpated channels: "
        console.log @channels


    return new Channels
