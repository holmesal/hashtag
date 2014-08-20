'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.message
 # @description
 # # message
 # Service in the shortwaveApp.
###
angular.module('shortwaveApp')
  .service 'Message', ($q, $rootScope, User) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    Message = 

      text: (text, channel) ->

        # Build a new message
        message = 
          type: 'text'
          content:
            text: text

        # Send - returns a promise
        @send message, channel

      image: (url, channel) ->

        # Build a new image message
        message =
          type: 'image'
          content:
            src: url

        # Send - returns a promise
        @send message, channel




      send: (message, channel) ->

        # Sent promise
        sent = $q.defer()

        message.owner = User.user.$id

        # Send the message
        pushRef = $rootScope.rootRef.child("messages/#{channel}").push()
        pushRef.setWithPriority message, Date.now(), (err) ->
          if err
            sent.reject err
          else
            request = 
              channel: channel
              message: pushRef.ref().name()
            # Queue a parse request for this message
            parseRef = $rootScope.rootRef.child('parseQueue').push()
            parseRef.set request, (err) ->
              if err
                sent.reject err
              else
                sent.resolve()

            # Queue a push request for this message
            pushRef = $rootScope.rootRef.child('pushQueue').push()
            pushRef.set request, (err) ->
              if err
                sent.reject err
              else
                sent.resolve()

        # Return the promise
        sent.promise
