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
        @firebaseAuth = $firebaseSimpleLogin @rootRef

        # Init
        @init()

      init: ->
        # User promise - if user isn't logged in, will be resolved with a null user
        @deferredUser = $q.defer()

        # Auth promise - if user isn't logged in, will be rejected
        @deferredAuth = $q.defer()
        

      get: ->
        # Authenticate and load
        @load()

        # Return the user promise - will be null if not logged in
        return @deferredUser.promise

      auth: ->
        # Authenticate and load
        @load()

        # Return the auth promise - will be rejected if not logged in
        return @deferredAuth.promise

      load: ->
        @firebaseAuth.$getCurrentUser().then (@authUser) =>
          console.info 'got current user!', authUser
          # @authUser is null if the user isn't logged in
          if @authUser
            # Resolve with the auth User
            @deferredAuth.resolve @authUser
            # Fetch the user from firebase
            @fetch()
          else
            @loggedIn = false
            # The user isn't logged in. Resolve the promise, but with a null user
            @deferredUser.resolve null
            # Reject the auth promise
            @deferredAuth.reject()
        .catch (err) ->
          console.error 'err getting current user'
          console.error err


      fetch: ->
        userRef = $rootScope.rootRef.child "users/#{@authUser.uid}"
        sync = $firebase userRef
        @user = sync.$asObject()

        # Once the user is loaded, resolve the main promise
        @user.$loaded().then (user) =>
          console.info 'user allegedly loaded', user
          # Now logged in
          @loggedIn = true
          # Resolve any routes
          @deferredUser.resolve user
          # Let other services know
          $rootScope.$broadcast 'userLoaded', user

      login: ->
        # Reset login promises
        @init()

        # Attempt to log in
        @firebaseAuth.$login 'facebook'
        .then =>
          # Get the user
          @get()
        , (err) ->
          console.error 'error logging in', err
          @deferredUser.reject()

        # Return the deferred user promise
        return @deferredUser.promise

    return new User

