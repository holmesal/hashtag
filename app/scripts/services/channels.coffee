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

        console.log 'making channels@'
        @channelList = 'hi!!!!'

        # Just naively assume a user already exists
        @user = User.getUser()

        # Watch the user's list of channels
        channelListRef = $rootScope.rootRef.child "users/#{@user.$id}/channels"
        channelListRef.on 'value', (snap) =>
          console.log 'changed!'
          console.log snap.val()
          @channelList = snap.val()
        # @channelList = $firebase channelListRef

        console.log @channelList

    return new Channels
