'use strict'

###*
 # @ngdoc service
 # @name shortwaveApp.user
 # @description
 # # user
 # Provides an interface to firebase
###
angular.module('shortwaveApp')
  .service 'User', ($rootScope, $firebase, $firebaseSimpleLogin, $q) ->

    class User 

      constructor: ->

        @rootRef = $rootScope.rootRef

        # Login object
        @auth = $firebaseSimpleLogin @rootRef

        # User promise
        @deferredUser = $q.defer()
        @prom = @deferredUser.promise

      get: ->
        # Returns a promise that will be resolved with the user and authUser.
        # If the user isn't logged in, will be resolved with null
        @auth.$getCurrentUser().then (@authUser) =>
          console.log 'got current user!'
          console.log authUser
          # @authUser is null if the user isn't logged in
          if @authUser
            # Fetch the user from firebase
            @fetch()
          else
            @loggedIn = false
            # The user isn't logged in. Resolve the promise, but with a null user
            @deferredUser.resolve null
        .catch (err) ->
          console.error 'err getting current user'
          console.error err

        return @prom

      fetch: ->
        userRef = $rootScope.rootRef.child "users/#{@authUser.uid}"
        sync = $firebase userRef
        @user = sync.$asObject()

        # Once the user is loaded, resolve the main promise
        @user.$loaded().then =>
          @loggedIn = true
          @deferredUser.resolve @user

    return new User

